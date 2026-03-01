import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/lead_status_mapper.dart';
import '../app_database.dart';
import '../tables/leads_table.dart';
import '../tables/pending_sync_actions_table.dart';

part 'leads_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [LocalLeads, PendingSyncActions])
class LeadsDao extends DatabaseAccessor<AppDatabase> with _$LeadsDaoMixin {
  LeadsDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// Watch all active (non-deleted) leads for an org, filtered by status.
  Stream<List<LocalLead>> watchLeadsByStatus(
    String orgId,
    String status,
  ) {
    return (select(localLeads)
          ..where((l) => l.organizationId.equals(orgId))
          ..where((l) => l.status.equals(status))
          ..where((l) => l.deletedAt.isNull())
          ..orderBy([
            (l) => OrderingTerm.desc(l.updatedAt),
          ]))
        .watch();
  }

  /// Watch all active (non-deleted) leads for an org, any status.
  Stream<List<LocalLead>> watchAllLeads(String orgId) {
    return (select(localLeads)
          ..where((l) => l.organizationId.equals(orgId))
          ..where((l) => l.deletedAt.isNull())
          ..orderBy([
            (l) => OrderingTerm.desc(l.updatedAt),
          ]))
        .watch();
  }

  /// Watch a single lead by ID.
  Stream<LocalLead?> watchLeadById(String leadId) {
    return (select(localLeads)..where((l) => l.id.equals(leadId)))
        .watchSingleOrNull();
  }

  /// Get a single lead by ID (one-shot).
  Future<LocalLead?> getLeadById(String leadId) {
    return (select(localLeads)..where((l) => l.id.equals(leadId)))
        .getSingleOrNull();
  }

  /// Watch won leads that have no linked active job (for Home screen reminder).
  Stream<List<LocalLead>> watchWonLeadsWithoutJob(String orgId) {
    // A lead is "won without job" when status=won and no active
    // local job references it via lead_id.
    return customSelect(
      'SELECT * FROM local_leads '
      'WHERE organization_id = ? '
      'AND status = \'won\' '
      'AND deleted_at IS NULL '
      'AND id NOT IN ('
      'SELECT lead_id FROM local_jobs '
      'WHERE lead_id IS NOT NULL AND deleted_at IS NULL'
      ')',
      variables: [Variable.withString(orgId)],
      readsFrom: {localLeads, db.localJobs},
    ).watch().map((rows) {
      return rows.map((row) => localLeads.map(row.data)).toList();
    });
  }

  /// Backward-compatible alias for older call sites.
  Stream<List<LocalLead>> watchWonLeadsWithoutProject(String orgId) {
    return watchWonLeadsWithoutJob(orgId);
  }

  // ── Mutations ────────────────────────────────────────────────────

  /// Create a new lead locally and queue a sync action.
  Future<void> createLead(LocalLeadsCompanion lead) {
    return transaction(() async {
      await into(localLeads).insert(
        lead.copyWith(needsSync: const Value(true)),
      );
      await _queueSync(
        entityType: 'lead',
        entityId: lead.id.value,
        mutationType: 'insert',
        baseVersion: null,
        payload: _leadCompanionToJson(lead),
      );
    });
  }

  /// Update lead status and queue a sync action.
  Future<void> updateLeadStatus(
    String leadId,
    String newStatus,
    int currentVersion,
  ) {
    return transaction(() async {
      final canonicalStatus = LeadStatusMapper.canonicalize(newStatus);
      final nextVersion = currentVersion + 1;
      await (update(localLeads)..where((l) => l.id.equals(leadId))).write(
        LocalLeadsCompanion(
          status: Value(canonicalStatus),
          version: Value(nextVersion),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'lead',
        entityId: leadId,
        mutationType: 'update',
        baseVersion: currentVersion,
        payload: {
          'id': leadId,
          'status': canonicalStatus,
          'version': nextVersion,
        },
      );
    });
  }

  /// Mark estimate sent and activate the lead follow-up state locally.
  Future<void> markEstimateSent(
    String leadId,
    int currentVersion, {
    DateTime? estimateSentAt,
  }) {
    return transaction(() async {
      final nextVersion = currentVersion + 1;
      final estimateAt = estimateSentAt ?? DateTime.now();
      await (update(localLeads)..where((l) => l.id.equals(leadId))).write(
        LocalLeadsCompanion(
          status: const Value(LeadStatusMapper.estimateDb),
          followupState: const Value('active'),
          estimateSentAt: Value(estimateAt),
          version: Value(nextVersion),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'lead',
        entityId: leadId,
        mutationType: 'update',
        baseVersion: currentVersion,
        payload: {
          'id': leadId,
          'status': LeadStatusMapper.estimateDb,
          'followup_state': 'active',
          'estimate_sent_at': estimateAt.toIso8601String(),
          'version': nextVersion,
        },
      );
    });
  }

  /// Update followup state on a lead.
  Future<void> updateFollowupState(
    String leadId,
    String newFollowupState,
    int currentVersion,
  ) {
    return transaction(() async {
      final nextVersion = currentVersion + 1;
      await (update(localLeads)..where((l) => l.id.equals(leadId))).write(
        LocalLeadsCompanion(
          followupState: Value(newFollowupState),
          version: Value(nextVersion),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'lead',
        entityId: leadId,
        mutationType: 'update',
        baseVersion: currentVersion,
        payload: {
          'id': leadId,
          'followup_state': newFollowupState,
          'version': nextVersion,
        },
      );
    });
  }

  /// Soft-delete a lead and queue a sync action.
  Future<void> softDeleteLead(String leadId, int currentVersion) {
    return transaction(() async {
      final now = DateTime.now();
      final nextVersion = currentVersion + 1;
      await (update(localLeads)..where((l) => l.id.equals(leadId))).write(
        LocalLeadsCompanion(
          deletedAt: Value(now),
          version: Value(nextVersion),
          updatedAt: Value(now),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'lead',
        entityId: leadId,
        mutationType: 'delete',
        baseVersion: currentVersion,
        payload: {
          'id': leadId,
          'deleted_at': now.toIso8601String(),
          'version': nextVersion,
        },
      );
    });
  }

  /// Bulk upsert leads from server (does NOT create outbox entries).
  Future<void> upsertFromServer(List<LocalLeadsCompanion> serverLeads) {
    return batch((b) {
      for (final lead in serverLeads) {
        b.insert(
          localLeads,
          lead.copyWith(
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

  Map<String, dynamic> _leadCompanionToJson(LocalLeadsCompanion c) {
    return {
      'id': c.id.value,
      'organization_id': c.organizationId.value,
      if (c.createdByProfileId.present)
        'created_by_profile_id': c.createdByProfileId.value,
      'client_name': c.clientName.value,
      if (c.phoneE164.present) 'phone_e164': c.phoneE164.value,
      if (c.email.present) 'email': c.email.value,
      'job_type': c.jobType.value,
      if (c.notes.present) 'notes': c.notes.value,
      if (c.status.present) 'status': c.status.value,
      if (c.followupState.present) 'followup_state': c.followupState.value,
    };
  }
}
