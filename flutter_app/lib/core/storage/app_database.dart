import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/leads_table.dart';
import 'tables/jobs_table.dart';
import 'tables/followup_sequences_table.dart';
import 'tables/followup_messages_table.dart';
import 'tables/call_logs_table.dart';
import 'tables/message_templates_table.dart';
import 'tables/organizations_table.dart';
import 'tables/profiles_table.dart';
import 'tables/pending_sync_actions_table.dart';
import 'tables/sync_cursors_table.dart';

import 'daos/leads_dao.dart';
import 'daos/jobs_dao.dart';
import 'daos/followups_dao.dart';
import 'daos/call_logs_dao.dart';
import 'daos/templates_dao.dart';
import 'daos/organizations_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalLeads,
    LocalJobs,
    LocalFollowupSequences,
    LocalFollowupMessages,
    LocalCallLogs,
    LocalMessageTemplates,
    LocalOrganizations,
    LocalProfiles,
    PendingSyncActions,
    SyncCursors,
  ],
  daos: [
    LeadsDao,
    JobsDao,
    FollowupsDao,
    CallLogsDao,
    TemplatesDao,
    OrganizationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Named constructor for production use — opens native SQLite file.
  AppDatabase.production() : super(_openConnection());

  /// Named constructor for tests — uses an in-memory database.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'crewcommand.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
