// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'templates_dao.dart';

// ignore_for_file: type=lint
mixin _$TemplatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalMessageTemplatesTable get localMessageTemplates =>
      attachedDatabase.localMessageTemplates;
  TemplatesDaoManager get managers => TemplatesDaoManager(this);
}

class TemplatesDaoManager {
  final _$TemplatesDaoMixin _db;
  TemplatesDaoManager(this._db);
  $$LocalMessageTemplatesTableTableManager get localMessageTemplates =>
      $$LocalMessageTemplatesTableTableManager(
          _db.attachedDatabase, _db.localMessageTemplates);
}
