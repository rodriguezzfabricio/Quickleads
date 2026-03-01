// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'templates_dao.dart';

// ignore_for_file: type=lint
mixin _$TemplatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalMessageTemplatesTable get localMessageTemplates =>
      attachedDatabase.localMessageTemplates;
  $PendingSyncActionsTable get pendingSyncActions =>
      attachedDatabase.pendingSyncActions;
  TemplatesDaoManager get managers => TemplatesDaoManager(this);
}

class TemplatesDaoManager {
  final _$TemplatesDaoMixin _db;
  TemplatesDaoManager(this._db);
  $$LocalMessageTemplatesTableTableManager get localMessageTemplates =>
      $$LocalMessageTemplatesTableTableManager(
          _db.attachedDatabase, _db.localMessageTemplates);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(
          _db.attachedDatabase, _db.pendingSyncActions);
}
