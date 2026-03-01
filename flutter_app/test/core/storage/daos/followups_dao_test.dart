import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:crewcommand_mobile/core/storage/app_database.dart';
import 'package:crewcommand_mobile/core/storage/daos/followups_dao.dart';

void main() {
  late AppDatabase db;
  late FollowupsDao followupsDao;

  setUp(() {
    db = AppDatabase.memory();
    followupsDao = db.followupsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('FollowupsDao', () {
    const orgId = 'org-001';

    final baseDate = DateTime(2026, 3, 1, 9, 0, 0);

    LocalFollowupSequencesCompanion makeSequence({
      required String id,
      required String leadId,
      String state = 'active',
    }) {
      return LocalFollowupSequencesCompanion.insert(
        id: id,
        organizationId: orgId,
        leadId: leadId,
        state: Value(state),
        startDateLocal: baseDate,
        timezone: 'America/New_York',
      );
    }

    LocalFollowupMessagesCompanion makeMessage({
      required String id,
      required String sequenceId,
      required int stepNumber,
    }) {
      return LocalFollowupMessagesCompanion.insert(
        id: id,
        sequenceId: sequenceId,
        stepNumber: stepNumber,
        channel: 'sms',
        templateKey: 'day_${stepNumber}_followup',
        scheduledAt: baseDate.add(Duration(days: stepNumber)),
      );
    }

    test('createSequence inserts a sequence and queues a sync insert',
        () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-1', leadId: 'lead-a'),
      );

      final sequences = await db.select(db.localFollowupSequences).get();
      expect(sequences, hasLength(1));
      expect(sequences.first.id, 'seq-1');
      expect(sequences.first.leadId, 'lead-a');
      expect(sequences.first.state, 'active');
      expect(sequences.first.needsSync, true);

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(1));
      expect(actions.first.entityType, 'followup_sequence');
      expect(actions.first.entityId, 'seq-1');
      expect(actions.first.mutationType, 'insert');
    });

    test('watchSequenceByLeadId returns the correct sequence', () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-a', leadId: 'lead-x'),
      );
      await followupsDao.createSequence(
        makeSequence(id: 'seq-b', leadId: 'lead-y'),
      );

      final seqForX = await followupsDao.watchSequenceByLeadId('lead-x').first;
      expect(seqForX, isNotNull);
      expect(seqForX!.id, 'seq-a');

      final seqForY = await followupsDao.watchSequenceByLeadId('lead-y').first;
      expect(seqForY, isNotNull);
      expect(seqForY!.id, 'seq-b');
    });

    test('updateSequenceState to paused sets state, pausedAt, and queues sync',
        () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-2', leadId: 'lead-b'),
      );

      await followupsDao.updateSequenceState('seq-2', 'paused');

      final seq = (await db.select(db.localFollowupSequences).get()).first;
      expect(seq.state, 'paused');
      expect(seq.pausedAt, isNotNull);
      expect(seq.stoppedAt, isNull);
      expect(seq.completedAt, isNull);
      expect(seq.needsSync, true);

      // 2 outbox entries: insert + state update.
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(2));
      expect(actions.last.mutationType, 'update');
    });

    test('updateSequenceState to stopped sets stoppedAt', () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-3', leadId: 'lead-c'),
      );

      await followupsDao.updateSequenceState('seq-3', 'stopped');

      final seq = (await db.select(db.localFollowupSequences).get()).first;
      expect(seq.state, 'stopped');
      expect(seq.stoppedAt, isNotNull);
      expect(seq.pausedAt, isNull);
    });

    test('updateSequenceState to completed sets completedAt', () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-4', leadId: 'lead-d'),
      );

      await followupsDao.updateSequenceState('seq-4', 'completed');

      final seq = (await db.select(db.localFollowupSequences).get()).first;
      expect(seq.state, 'completed');
      expect(seq.completedAt, isNotNull);
    });

    test('watchActiveSequences only returns sequences with state=active',
        () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-5a', leadId: 'lead-e1', state: 'active'),
      );
      await followupsDao.createSequence(
        makeSequence(id: 'seq-5b', leadId: 'lead-e2', state: 'paused'),
      );
      await followupsDao.createSequence(
        makeSequence(id: 'seq-5c', leadId: 'lead-e3', state: 'stopped'),
      );

      final activeSequences =
          await followupsDao.watchActiveSequences(orgId).first;
      expect(activeSequences, hasLength(1));
      expect(activeSequences.first.id, 'seq-5a');
    });

    test('watchMessagesBySequenceId returns messages ordered by stepNumber',
        () async {
      await followupsDao.createSequence(
        makeSequence(id: 'seq-6', leadId: 'lead-f'),
      );

      // Insert messages out of order.
      await db.batch((b) {
        b.insert(db.localFollowupMessages,
            makeMessage(id: 'msg-day10', sequenceId: 'seq-6', stepNumber: 10));
        b.insert(db.localFollowupMessages,
            makeMessage(id: 'msg-day2', sequenceId: 'seq-6', stepNumber: 2));
        b.insert(db.localFollowupMessages,
            makeMessage(id: 'msg-day5', sequenceId: 'seq-6', stepNumber: 5));
      });

      final messages =
          await followupsDao.watchMessagesBySequenceId('seq-6').first;
      expect(messages, hasLength(3));
      expect(messages[0].stepNumber, 2);
      expect(messages[1].stepNumber, 5);
      expect(messages[2].stepNumber, 10);
    });

    test(
        'upsertSequencesFromServer saves sequences without creating outbox entries',
        () async {
      final serverSeq = LocalFollowupSequencesCompanion.insert(
        id: 'server-seq-1',
        organizationId: orgId,
        leadId: 'lead-server',
        state: const Value('active'),
        startDateLocal: baseDate,
        timezone: 'America/New_York',
      );

      await followupsDao.upsertSequencesFromServer([serverSeq]);

      final sequences = await db.select(db.localFollowupSequences).get();
      expect(sequences, hasLength(1));
      expect(sequences.first.id, 'server-seq-1');
      expect(sequences.first.needsSync, false);
      expect(sequences.first.lastSyncedAt, isNotNull);

      // No outbox entries.
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, isEmpty);
    });

    test(
        'upsertMessagesFromServer saves messages without creating outbox entries',
        () async {
      final serverMsg = LocalFollowupMessagesCompanion.insert(
        id: 'server-msg-1',
        sequenceId: 'seq-server',
        stepNumber: 2,
        channel: 'sms',
        templateKey: 'day_2_followup',
        scheduledAt: baseDate.add(const Duration(days: 2)),
      );

      await followupsDao.upsertMessagesFromServer([serverMsg]);

      final messages = await db.select(db.localFollowupMessages).get();
      expect(messages, hasLength(1));
      expect(messages.first.id, 'server-msg-1');
      expect(messages.first.needsSync, false);
      expect(messages.first.lastSyncedAt, isNotNull);

      // No outbox entries.
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, isEmpty);
    });
  });
}
