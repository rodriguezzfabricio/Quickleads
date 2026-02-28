import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/followup_sequences_table.dart';
import '../tables/followup_messages_table.dart';
import '../tables/pending_sync_actions_table.dart';

part 'followups_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(
  tables: [LocalFollowupSequences, LocalFollowupMessages, PendingSyncActions],
)
class FollowupsDao extends DatabaseAccessor<AppDatabase>
    with _$FollowupsDaoMixin {
  FollowupsDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// Watch the followup sequence for a specific lead.
  Stream<LocalFollowupSequence?> watchSequenceByLeadId(String leadId) {
    return (select(localFollowupSequences)
          ..where((s) => s.leadId.equals(leadId)))
        .watchSingleOrNull();
  }

  /// Watch all messages for a sequence.
  Stream<List<LocalFollowupMessage>> watchMessagesBySequenceId(
    String sequenceId,
  ) {
    return (select(localFollowupMessages)
          ..where((m) => m.sequenceId.equals(sequenceId))
          ..orderBy([(m) => OrderingTerm.asc(m.stepNumber)]))
        .watch();
  }

  /// Watch all active sequences for an org.
  Stream<List<LocalFollowupSequence>> watchActiveSequences(String orgId) {
    return (select(localFollowupSequences)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.state.equals('active'))
          ..orderBy([(s) => OrderingTerm.asc(s.nextSendAt)]))
        .watch();
  }

  // ── Mutations ────────────────────────────────────────────────────

  /// Create a followup sequence locally and queue sync.
  Future<void> createSequence(LocalFollowupSequencesCompanion seq) {
    return transaction(() async {
      await into(localFollowupSequences).insert(
        seq.copyWith(needsSync: const Value(true)),
      );
      await _queueSync(
        entityType: 'followup_sequence',
        entityId: seq.id.value,
        mutationType: 'insert',
        baseVersion: null,
        payload: {
          'id': seq.id.value,
          'organization_id': seq.organizationId.value,
          'lead_id': seq.leadId.value,
          'state': seq.state.present ? seq.state.value : 'active',
          'start_date_local':
              seq.startDateLocal.value.toIso8601String(),
          'timezone': seq.timezone.value,
        },
      );
    });
  }

  /// Update the state of a followup sequence (pause/stop/complete).
  Future<void> updateSequenceState(
    String sequenceId,
    String newState,
  ) {
    return transaction(() async {
      final now = DateTime.now();
      final updates = LocalFollowupSequencesCompanion(
        state: Value(newState),
        updatedAt: Value(now),
        needsSync: const Value(true),
        pausedAt: newState == 'paused' ? Value(now) : const Value.absent(),
        stoppedAt: newState == 'stopped' ? Value(now) : const Value.absent(),
        completedAt:
            newState == 'completed' ? Value(now) : const Value.absent(),
      );
      await (update(localFollowupSequences)
            ..where((s) => s.id.equals(sequenceId)))
          .write(updates);
      await _queueSync(
        entityType: 'followup_sequence',
        entityId: sequenceId,
        mutationType: 'update',
        baseVersion: null,
        payload: {'state': newState},
      );
    });
  }

  /// Bulk upsert sequences from server (no outbox entries).
  Future<void> upsertSequencesFromServer(
    List<LocalFollowupSequencesCompanion> sequences,
  ) {
    return batch((b) {
      for (final seq in sequences) {
        b.insert(
          localFollowupSequences,
          seq.copyWith(
            needsSync: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Bulk upsert messages from server (no outbox entries).
  Future<void> upsertMessagesFromServer(
    List<LocalFollowupMessagesCompanion> messages,
  ) {
    return batch((b) {
      for (final msg in messages) {
        b.insert(
          localFollowupMessages,
          msg.copyWith(
            needsSync: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Future<void> _queueSync({
    required String entityType,
    required String entityId,
    required String mutationType,
    required int? baseVersion,
    required Map<String, dynamic> payload,
  }) {
    return into(pendingSyncActions).insert(
      PendingSyncActionsCompanion.insert(
        id: _uuid.v4(),
        clientMutationId: _uuid.v4(),
        entityType: entityType,
        entityId: Value(entityId),
        mutationType: mutationType,
        baseVersion: Value(baseVersion),
        payload: jsonEncode(payload),
      ),
    );
  }
}
