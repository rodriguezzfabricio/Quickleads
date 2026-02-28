import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/call_logs_table.dart';
import '../tables/pending_sync_actions_table.dart';

part 'call_logs_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [LocalCallLogs, PendingSyncActions])
class CallLogsDao extends DatabaseAccessor<AppDatabase>
    with _$CallLogsDaoMixin {
  CallLogsDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// Watch recent call logs for an org, newest first.
  Stream<List<LocalCallLog>> watchRecentCallLogs(
    String orgId, {
    int limit = 50,
  }) {
    return (select(localCallLogs)
          ..where((c) => c.organizationId.equals(orgId))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)])
          ..limit(limit))
        .watch();
  }

  /// Watch unknown calls (disposition = 'unknown') for Daily Sweep.
  Stream<List<LocalCallLog>> watchUnknownCalls(String orgId) {
    return (select(localCallLogs)
          ..where((c) => c.organizationId.equals(orgId))
          ..where((c) => c.disposition.equals('unknown'))
          ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
        .watch();
  }

  // ── Mutations ────────────────────────────────────────────────────

  /// Insert a call log locally and queue sync.
  Future<void> insertCallLog(LocalCallLogsCompanion callLog) {
    return transaction(() async {
      await into(localCallLogs).insert(
        callLog.copyWith(needsSync: const Value(true)),
      );
      await _queueSync(
        entityType: 'call_log',
        entityId: callLog.id.value,
        mutationType: 'insert',
        payload: {
          'id': callLog.id.value,
          'organization_id': callLog.organizationId.value,
          'phone_e164': callLog.phoneE164.value,
          'platform': callLog.platform.value,
          'source': callLog.source.value,
          'started_at': callLog.startedAt.value.toIso8601String(),
          if (callLog.durationSec.present)
            'duration_sec': callLog.durationSec.value,
          if (callLog.disposition.present)
            'disposition': callLog.disposition.value,
        },
      );
    });
  }

  /// Update disposition (e.g. saved_as_lead, skipped) and queue sync.
  Future<void> updateDisposition(
    String callLogId,
    String newDisposition,
  ) {
    return transaction(() async {
      await (update(localCallLogs)
            ..where((c) => c.id.equals(callLogId)))
          .write(
        LocalCallLogsCompanion(
          disposition: Value(newDisposition),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'call_log',
        entityId: callLogId,
        mutationType: 'update',
        payload: {'disposition': newDisposition},
      );
    });
  }

  /// Bulk upsert call logs from server (no outbox entries).
  Future<void> upsertFromServer(
    List<LocalCallLogsCompanion> serverCallLogs,
  ) {
    return batch((b) {
      for (final log in serverCallLogs) {
        b.insert(
          localCallLogs,
          log.copyWith(
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
    required Map<String, dynamic> payload,
  }) {
    return into(pendingSyncActions).insert(
      PendingSyncActionsCompanion.insert(
        id: _uuid.v4(),
        clientMutationId: _uuid.v4(),
        entityType: entityType,
        entityId: Value(entityId),
        mutationType: mutationType,
        payload: jsonEncode(payload),
      ),
    );
  }
}
