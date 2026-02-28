// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followups_dao.dart';

// ignore_for_file: type=lint
mixin _$FollowupsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalFollowupSequencesTable get localFollowupSequences =>
      attachedDatabase.localFollowupSequences;
  $LocalFollowupMessagesTable get localFollowupMessages =>
      attachedDatabase.localFollowupMessages;
  $PendingSyncActionsTable get pendingSyncActions =>
      attachedDatabase.pendingSyncActions;
  FollowupsDaoManager get managers => FollowupsDaoManager(this);
}

class FollowupsDaoManager {
  final _$FollowupsDaoMixin _db;
  FollowupsDaoManager(this._db);
  $$LocalFollowupSequencesTableTableManager get localFollowupSequences =>
      $$LocalFollowupSequencesTableTableManager(
          _db.attachedDatabase, _db.localFollowupSequences);
  $$LocalFollowupMessagesTableTableManager get localFollowupMessages =>
      $$LocalFollowupMessagesTableTableManager(
          _db.attachedDatabase, _db.localFollowupMessages);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(
          _db.attachedDatabase, _db.pendingSyncActions);
}
