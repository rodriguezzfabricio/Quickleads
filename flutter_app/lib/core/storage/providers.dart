import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/supabase_client.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_status.dart';
import 'app_database.dart';
import 'daos/leads_dao.dart';
import 'daos/jobs_dao.dart';
import 'daos/followups_dao.dart';
import 'daos/call_logs_dao.dart';
import 'daos/templates_dao.dart';

// ── Database ────────────────────────────────────────────────────────

/// Singleton database instance, opened lazily.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.production();
  ref.onDispose(() => db.close());
  return db;
});

// ── DAOs ────────────────────────────────────────────────────────────

final leadsDaoProvider = Provider<LeadsDao>((ref) {
  return ref.watch(appDatabaseProvider).leadsDao;
});

final jobsDaoProvider = Provider<JobsDao>((ref) {
  return ref.watch(appDatabaseProvider).jobsDao;
});

final followupsDaoProvider = Provider<FollowupsDao>((ref) {
  return ref.watch(appDatabaseProvider).followupsDao;
});

final callLogsDaoProvider = Provider<CallLogsDao>((ref) {
  return ref.watch(appDatabaseProvider).callLogsDao;
});

final templatesDaoProvider = Provider<TemplatesDao>((ref) {
  return ref.watch(appDatabaseProvider).templatesDao;
});

// ── Sync Engine ─────────────────────────────────────────────────────

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final engine = SyncEngine(db: db, supabaseClient: supabase);
  engine.startListening();
  ref.onDispose(() => engine.dispose());
  return engine;
});

/// Stream of current sync status for UI indicators.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.statusStream;
});

// ── Reactive Streams for UI ─────────────────────────────────────────

/// Watch leads by status for a given organization.
final leadsByStatusProvider =
    StreamProvider.family<List<LocalLead>, ({String orgId, String status})>(
  (ref, params) {
    return ref
        .watch(leadsDaoProvider)
        .watchLeadsByStatus(params.orgId, params.status);
  },
);

/// Watch all leads for a given organization.
final allLeadsProvider = StreamProvider.family<List<LocalLead>, String>(
  (ref, orgId) {
    return ref.watch(leadsDaoProvider).watchAllLeads(orgId);
  },
);

/// Watch won leads that have no linked active job.
final wonLeadsWithoutJobProvider =
    StreamProvider.family<List<LocalLead>, String>(
  (ref, orgId) {
    return ref.watch(leadsDaoProvider).watchWonLeadsWithoutJob(orgId);
  },
);

/// Backward-compatible alias for older consumers.
final wonLeadsWithoutProjectProvider =
    StreamProvider.family<List<LocalLead>, String>(
  (ref, orgId) {
    return ref.watch(leadsDaoProvider).watchWonLeadsWithoutJob(orgId);
  },
);

/// Watch all jobs for a given organization.
final jobsByOrgProvider = StreamProvider.family<List<LocalJob>, String>(
  (ref, orgId) {
    return ref.watch(jobsDaoProvider).watchJobsByOrg(orgId);
  },
);

/// Watch the active job linked to a lead.
final jobForLeadProvider = StreamProvider.family<LocalJob?, String>(
  (ref, leadId) {
    return ref.watch(jobsDaoProvider).watchJobByLeadId(leadId);
  },
);

/// Watch jobs for an org filtered by health status.
final jobsByHealthStatusProvider =
    StreamProvider.family<List<LocalJob>, ({String orgId, String healthStatus})>(
  (ref, params) {
    return ref
        .watch(jobsDaoProvider)
        .watchJobsByHealthStatus(params.orgId, params.healthStatus);
  },
);

/// Watch a single job by ID.
final jobByIdProvider = StreamProvider.family<LocalJob?, String>(
  (ref, jobId) {
    return ref.watch(jobsDaoProvider).watchJobById(jobId);
  },
);
