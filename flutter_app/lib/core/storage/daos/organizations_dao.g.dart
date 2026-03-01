// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizations_dao.dart';

// ignore_for_file: type=lint
mixin _$OrganizationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalOrganizationsTable get localOrganizations =>
      attachedDatabase.localOrganizations;
  $LocalProfilesTable get localProfiles => attachedDatabase.localProfiles;
  OrganizationsDaoManager get managers => OrganizationsDaoManager(this);
}

class OrganizationsDaoManager {
  final _$OrganizationsDaoMixin _db;
  OrganizationsDaoManager(this._db);
  $$LocalOrganizationsTableTableManager get localOrganizations =>
      $$LocalOrganizationsTableTableManager(
          _db.attachedDatabase, _db.localOrganizations);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db.attachedDatabase, _db.localProfiles);
}
