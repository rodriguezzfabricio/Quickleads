import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crewcommand_mobile/core/storage/app_database.dart';
import 'package:crewcommand_mobile/core/storage/daos/leads_dao.dart';

void main() {
  late AppDatabase db;
  late LeadsDao leadsDao;

  setUp(() {
    db = AppDatabase.memory();
    leadsDao = db.leadsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('LeadsDao', () {
    const orgId = 'org-001';
    const profileId = 'profile-001';

    LocalLeadsCompanion _makeLead({
      required String id,
      String status = 'new_callback',
      String? phone,
    }) {
      return LocalLeadsCompanion.insert(
        id: id,
        organizationId: orgId,
        clientName: 'Test Lead $id',
        jobType: 'Kitchen Remodel',
        createdByProfileId: Value(profileId),
        phoneE164: Value(phone),
        status: Value(status),
      );
    }

    test('createLead inserts a lead and returns it via query', () async {
      final lead = _makeLead(id: 'lead-1', phone: '+15551234567');

      await leadsDao.createLead(lead);

      final result = await leadsDao.getLeadById('lead-1');
      expect(result, isNotNull);
      expect(result!.clientName, 'Test Lead lead-1');
      expect(result.organizationId, orgId);
      expect(result.jobType, 'Kitchen Remodel');
      expect(result.phoneE164, '+15551234567');
      expect(result.status, 'new_callback');
      expect(result.version, 1);
      expect(result.needsSync, true);
    });

    test('createLead queues a PendingSyncActions entry', () async {
      final lead = _makeLead(id: 'lead-2');

      await leadsDao.createLead(lead);

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(1));
      expect(actions.first.entityType, 'lead');
      expect(actions.first.entityId, 'lead-2');
      expect(actions.first.mutationType, 'insert');
      expect(actions.first.status, 'pending');
      expect(actions.first.clientMutationId, isNotEmpty);
    });

    test('updateLeadStatus updates status and queues sync', () async {
      await leadsDao.createLead(_makeLead(id: 'lead-3'));

      await leadsDao.updateLeadStatus('lead-3', 'estimate_sent', 1);

      final lead = await leadsDao.getLeadById('lead-3');
      expect(lead!.status, 'estimate_sent');
      expect(lead.needsSync, true);

      // Should have 2 outbox entries: the create + the status update
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(2));
      expect(actions.last.mutationType, 'status_transition');
    });

    test('softDeleteLead sets deletedAt and queues sync', () async {
      await leadsDao.createLead(_makeLead(id: 'lead-4'));

      await leadsDao.softDeleteLead('lead-4', 1);

      final lead = await leadsDao.getLeadById('lead-4');
      expect(lead!.deletedAt, isNotNull);
      expect(lead.needsSync, true);

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions.last.mutationType, 'delete');
    });

    test('watchLeadsByStatus emits when a lead is inserted', () async {
      // Start watching before inserting.
      final stream = leadsDao.watchLeadsByStatus(orgId, 'new_callback');
      final future = stream.first;

      await leadsDao.createLead(_makeLead(id: 'lead-5'));

      final results = await future;
      expect(results, isNotEmpty);
      expect(results.first.id, 'lead-5');
    });

    test('upsertFromServer saves without creating outbox entries', () async {
      final serverLead = LocalLeadsCompanion.insert(
        id: 'server-lead-1',
        organizationId: orgId,
        clientName: 'Server Lead',
        jobType: 'Bathroom Remodel',
        status: const Value('won'),
      );

      await leadsDao.upsertFromServer([serverLead]);

      final lead = await leadsDao.getLeadById('server-lead-1');
      expect(lead, isNotNull);
      expect(lead!.clientName, 'Server Lead');
      expect(lead.status, 'won');
      expect(lead.needsSync, false);
      expect(lead.lastSyncedAt, isNotNull);

      // No outbox entries should exist (upsertFromServer doesn't queue sync).
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, isEmpty);
    });

    test('deleted leads are excluded from watchLeadsByStatus', () async {
      await leadsDao.createLead(_makeLead(id: 'lead-6'));
      await leadsDao.softDeleteLead('lead-6', 1);

      // Give the stream a moment, then check.
      final results =
          await leadsDao.watchLeadsByStatus(orgId, 'new_callback').first;
      expect(results, isEmpty);
    });
  });
}
