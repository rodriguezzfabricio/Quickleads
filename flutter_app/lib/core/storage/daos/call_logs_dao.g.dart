// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_logs_dao.dart';

// ignore_for_file: type=lint
mixin _$CallLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalCallLogsTable get localCallLogs => attachedDatabase.localCallLogs;
  $PendingSyncActionsTable get pendingSyncActions =>
      attachedDatabase.pendingSyncActions;
  CallLogsDaoManager get managers => CallLogsDaoManager(this);
}

class CallLogsDaoManager {
  final _$CallLogsDaoMixin _db;
  CallLogsDaoManager(this._db);
  $$LocalCallLogsTableTableManager get localCallLogs =>
      $$LocalCallLogsTableTableManager(_db.attachedDatabase, _db.localCallLogs);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(
          _db.attachedDatabase, _db.pendingSyncActions);
}
