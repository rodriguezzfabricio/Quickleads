// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leads_dao.dart';

// ignore_for_file: type=lint
mixin _$LeadsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalLeadsTable get localLeads => attachedDatabase.localLeads;
  $PendingSyncActionsTable get pendingSyncActions =>
      attachedDatabase.pendingSyncActions;
  LeadsDaoManager get managers => LeadsDaoManager(this);
}

class LeadsDaoManager {
  final _$LeadsDaoMixin _db;
  LeadsDaoManager(this._db);
  $$LocalLeadsTableTableManager get localLeads =>
      $$LocalLeadsTableTableManager(_db.attachedDatabase, _db.localLeads);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(
          _db.attachedDatabase, _db.pendingSyncActions);
}
