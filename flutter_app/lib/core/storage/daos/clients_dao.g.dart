// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_dao.dart';

// ignore_for_file: type=lint
mixin _$ClientsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalClientsTable get localClients => attachedDatabase.localClients;
  $PendingSyncActionsTable get pendingSyncActions =>
      attachedDatabase.pendingSyncActions;
  ClientsDaoManager get managers => ClientsDaoManager(this);
}

class ClientsDaoManager {
  final _$ClientsDaoMixin _db;
  ClientsDaoManager(this._db);
  $$LocalClientsTableTableManager get localClients =>
      $$LocalClientsTableTableManager(_db.attachedDatabase, _db.localClients);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(
          _db.attachedDatabase, _db.pendingSyncActions);
}
