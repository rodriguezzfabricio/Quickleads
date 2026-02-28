import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/jobs_table.dart';
import '../tables/pending_sync_actions_table.dart';

part 'jobs_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [LocalJobs, PendingSyncActions])
class JobsDao extends DatabaseAccessor<AppDatabase> with _$JobsDaoMixin {
  JobsDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// Watch all active (non-deleted) jobs for an org.
  Stream<List<LocalJob>> watchJobsByOrg(String orgId) {
    return (select(localJobs)
          ..where((j) => j.organizationId.equals(orgId))
          ..where((j) => j.deletedAt.isNull())
          ..orderBy([
            (j) => OrderingTerm.desc(j.updatedAt),
          ]))
        .watch();
  }

  /// Watch a single job by ID.
  Stream<LocalJob?> watchJobById(String jobId) {
    return (select(localJobs)..where((j) => j.id.equals(jobId)))
        .watchSingleOrNull();
  }

  /// Get a single job by ID (one-shot).
  Future<LocalJob?> getJobById(String jobId) {
    return (select(localJobs)..where((j) => j.id.equals(jobId)))
        .getSingleOrNull();
  }

  // ── Mutations ────────────────────────────────────────────────────

  /// Create a new job locally and queue a sync action.
  Future<void> createJob(LocalJobsCompanion job) {
    return transaction(() async {
      await into(localJobs).insert(
        job.copyWith(needsSync: const Value(true)),
      );
      await _queueSync(
        entityType: 'job',
        entityId: job.id.value,
        mutationType: 'insert',
        baseVersion: null,
        payload: _jobCompanionToJson(job),
      );
    });
  }

  /// Update job phase and queue a sync action.
  Future<void> updateJobPhase(
    String jobId,
    String newPhase,
    int currentVersion,
  ) {
    return transaction(() async {
      await (update(localJobs)..where((j) => j.id.equals(jobId))).write(
        LocalJobsCompanion(
          phase: Value(newPhase),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'job',
        entityId: jobId,
        mutationType: 'update',
        baseVersion: currentVersion,
        payload: {'phase': newPhase},
      );
    });
  }

  /// Update job health status and queue a sync action.
  Future<void> updateJobHealthStatus(
    String jobId,
    String newHealthStatus,
    int currentVersion,
  ) {
    return transaction(() async {
      await (update(localJobs)..where((j) => j.id.equals(jobId))).write(
        LocalJobsCompanion(
          healthStatus: Value(newHealthStatus),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'job',
        entityId: jobId,
        mutationType: 'update',
        baseVersion: currentVersion,
        payload: {'health_status': newHealthStatus},
      );
    });
  }

  /// Soft-delete a job and queue a sync action.
  Future<void> softDeleteJob(String jobId, int currentVersion) {
    return transaction(() async {
      final now = DateTime.now();
      await (update(localJobs)..where((j) => j.id.equals(jobId))).write(
        LocalJobsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          needsSync: const Value(true),
        ),
      );
      await _queueSync(
        entityType: 'job',
        entityId: jobId,
        mutationType: 'delete',
        baseVersion: currentVersion,
        payload: {'deleted_at': now.toIso8601String()},
      );
    });
  }

  /// Bulk upsert jobs from server (does NOT create outbox entries).
  Future<void> upsertFromServer(List<LocalJobsCompanion> serverJobs) {
    return batch((b) {
      for (final job in serverJobs) {
        b.insert(
          localJobs,
          job.copyWith(
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

  Map<String, dynamic> _jobCompanionToJson(LocalJobsCompanion c) {
    return {
      'id': c.id.value,
      'organization_id': c.organizationId.value,
      if (c.leadId.present) 'lead_id': c.leadId.value,
      'client_name': c.clientName.value,
      'job_type': c.jobType.value,
      if (c.phase.present) 'phase': c.phase.value,
      if (c.healthStatus.present) 'health_status': c.healthStatus.value,
    };
  }
}
