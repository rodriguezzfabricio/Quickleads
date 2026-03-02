import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/supabase_client.dart';
import '../notifications/notification_service.dart';
import '../services/photo_upload_service.dart';
import '../services/lead_actions_service.dart';
import '../sync/device_registration_service.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_status.dart';
import 'app_database.dart';
import 'daos/call_logs_dao.dart';
import 'daos/clients_dao.dart';
import 'daos/followups_dao.dart';
import 'daos/job_photos_dao.dart';
import 'daos/jobs_dao.dart';
import 'daos/leads_dao.dart';
import 'daos/organizations_dao.dart';
import 'daos/templates_dao.dart';
import 'debug/mock_data_seed.dart';

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

final organizationsDaoProvider = Provider<OrganizationsDao>((ref) {
  return ref.watch(appDatabaseProvider).organizationsDao;
});

final jobPhotosDaoProvider = Provider<JobPhotosDao>((ref) {
  return ref.watch(appDatabaseProvider).jobPhotosDao;
});

final clientsDaoProvider = Provider<ClientsDao>((ref) {
  return ref.watch(appDatabaseProvider).clientsDao;
});

final photoUploadServiceProvider = Provider<PhotoUploadService>((ref) {
  return PhotoUploadService(
    jobPhotosDao: ref.watch(jobPhotosDaoProvider),
  );
});

// ── Sync Engine ─────────────────────────────────────────────────────

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final deviceRegistrationService =
      ref.watch(deviceRegistrationServiceProvider);
  final engine = SyncEngine(
    db: db,
    supabaseClient: supabase,
    deviceRegistrationService: deviceRegistrationService,
    photoUploadService: ref.watch(photoUploadServiceProvider),
  );
  engine.startListening();
  ref.onDispose(() => engine.dispose());
  return engine;
});

final deviceRegistrationServiceProvider =
    Provider<DeviceRegistrationService>((ref) {
  return DeviceRegistrationService(
    db: ref.watch(appDatabaseProvider),
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final leadActionsServiceProvider = Provider<LeadActionsService>((ref) {
  return DriftLeadActionsService(
    leadsDao: ref.watch(leadsDaoProvider),
    followupsDao: ref.watch(followupsDaoProvider),
    organizationsDao: ref.watch(organizationsDaoProvider),
    notificationScheduler: NotificationService.instance,
    supabaseClient: ref.watch(supabaseClientProvider),
    syncEngine: ref.watch(syncEngineProvider),
  );
});

/// Stream of current sync status for UI indicators.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.statusStream;
});

/// Stream of sync diagnostics for Settings UI.
final syncDiagnosticsProvider = StreamProvider<SyncDiagnostics>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.diagnosticsStream;
});

/// Last registered server-side device id for the current install.
final registeredServerDeviceIdProvider = FutureProvider<String?>((ref) async {
  return ref
      .watch(deviceRegistrationServiceProvider)
      .readRegisteredServerDeviceId();
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

final leadByIdProvider = StreamProvider.family<LocalLead?, String>(
  (ref, leadId) {
    return ref.watch(leadsDaoProvider).watchLeadById(leadId);
  },
);

/// Watch the active job linked to a lead.
final jobForLeadProvider = StreamProvider.family<LocalJob?, String>(
  (ref, leadId) {
    return ref.watch(jobsDaoProvider).watchJobByLeadId(leadId);
  },
);

/// Watch jobs for an org filtered by health status.
final jobsByHealthStatusProvider = StreamProvider.family<List<LocalJob>,
    ({String orgId, String healthStatus})>(
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

final photosByJobProvider = StreamProvider.family<List<LocalJobPhoto>, String>(
  (ref, jobId) {
    return ref.watch(jobPhotosDaoProvider).watchPhotosByJob(jobId);
  },
);

final clientsByOrgProvider = StreamProvider.family<List<LocalClient>, String>(
  (ref, orgId) {
    return ref.watch(clientsDaoProvider).watchClientsByOrg(orgId);
  },
);

final clientByIdProvider = StreamProvider.family<LocalClient?, String>(
  (ref, clientId) {
    return ref.watch(clientsDaoProvider).watchClientById(clientId);
  },
);

/// Watch follow-up sequence for a lead.
final followupSequenceByLeadProvider =
    StreamProvider.family<LocalFollowupSequence?, String>(
  (ref, leadId) {
    return ref.watch(followupsDaoProvider).watchSequenceByLeadId(leadId);
  },
);

/// Watch follow-up messages for a sequence.
final followupMessagesBySequenceProvider =
    StreamProvider.family<List<LocalFollowupMessage>, String>(
  (ref, sequenceId) {
    return ref
        .watch(followupsDaoProvider)
        .watchMessagesBySequenceId(sequenceId);
  },
);

/// Watch unknown calls for daily sweep review.
final unknownCallsProvider = StreamProvider.family<List<LocalCallLog>, String>(
  (ref, orgId) {
    return ref.watch(callLogsDaoProvider).watchUnknownCalls(orgId);
  },
);

/// Watch an organization by ID.
final organizationProvider = StreamProvider.family<LocalOrganization?, String>(
  (ref, orgId) {
    return ref.watch(organizationsDaoProvider).watchOrganization(orgId);
  },
);

/// Watch a user profile by ID.
final profileProvider = StreamProvider.family<LocalProfile?, String>(
  (ref, profileId) {
    return ref.watch(organizationsDaoProvider).watchProfile(profileId);
  },
);

/// Watch all active message templates for an org.
final activeTemplatesProvider =
    StreamProvider.family<List<LocalMessageTemplate>, String>(
  (ref, orgId) {
    return ref.watch(templatesDaoProvider).watchActiveTemplates(orgId);
  },
);

/// Debug-only seeding hook so simulator has realistic local data.
final debugMockDataSeedProvider = FutureProvider.family<void, String>(
  (ref, orgId) async {
    if (orgId.isEmpty) {
      return;
    }
    await seedDebugMockData(
      db: ref.read(appDatabaseProvider),
      organizationId: orgId,
    );
  },
);
