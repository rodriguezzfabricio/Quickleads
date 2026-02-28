// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_dao.dart';

// ignore_for_file: type=lint
mixin _$JobsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalJobsTable get localJobs => attachedDatabase.localJobs;
  $PendingSyncActionsTable get pendingSyncActions =>
      attachedDatabase.pendingSyncActions;
  JobsDaoManager get managers => JobsDaoManager(this);
}

class JobsDaoManager {
  final _$JobsDaoMixin _db;
  JobsDaoManager(this._db);
  $$LocalJobsTableTableManager get localJobs =>
      $$LocalJobsTableTableManager(_db.attachedDatabase, _db.localJobs);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(
          _db.attachedDatabase, _db.pendingSyncActions);
}
