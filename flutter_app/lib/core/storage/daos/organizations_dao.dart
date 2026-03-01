import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/organizations_table.dart';
import '../tables/profiles_table.dart';

part 'organizations_dao.g.dart';

@DriftAccessor(tables: [LocalOrganizations, LocalProfiles])
class OrganizationsDao extends DatabaseAccessor<AppDatabase>
    with _$OrganizationsDaoMixin {
  OrganizationsDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// Watch a single organization by ID.
  Stream<LocalOrganization?> watchOrganization(String orgId) {
    return (select(localOrganizations)..where((o) => o.id.equals(orgId)))
        .watchSingleOrNull();
  }

  /// Get a single organization by ID (one-shot).
  Future<LocalOrganization?> getOrganization(String orgId) {
    return (select(localOrganizations)..where((o) => o.id.equals(orgId)))
        .getSingleOrNull();
  }

  /// Watch a single profile by ID.
  Stream<LocalProfile?> watchProfile(String profileId) {
    return (select(localProfiles)..where((p) => p.id.equals(profileId)))
        .watchSingleOrNull();
  }

  /// Get a single profile by ID (one-shot).
  Future<LocalProfile?> getProfile(String profileId) {
    return (select(localProfiles)..where((p) => p.id.equals(profileId)))
        .getSingleOrNull();
  }

  /// Get a profile by auth user ID (one-shot).
  Future<LocalProfile?> getProfileByAuthUserId(String authUserId) {
    return (select(localProfiles)
          ..where((p) => p.authUserId.equals(authUserId)))
        .getSingleOrNull();
  }

  // ── Mutations ────────────────────────────────────────────────────

  /// Upsert an organization (used during workspace bootstrap and sync pull).
  Future<void> upsertOrganization(LocalOrganizationsCompanion org) async {
    await into(localOrganizations).insertOnConflictUpdate(org);
  }

  /// Upsert a profile (used during auth bootstrap and sync pull).
  Future<void> upsertProfile(LocalProfilesCompanion profile) async {
    await into(localProfiles).insertOnConflictUpdate(profile);
  }

  /// Update just the organization name field.
  Future<void> updateOrganizationName(String orgId, String name) async {
    await (update(localOrganizations)..where((o) => o.id.equals(orgId))).write(
      LocalOrganizationsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update the contractor's display name on their profile.
  Future<void> updateProfileName(String profileId, String fullName) async {
    await (update(localProfiles)..where((p) => p.id.equals(profileId))).write(
      LocalProfilesCompanion(
        fullName: Value(fullName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update the contractor's phone number on their profile.
  Future<void> updateProfilePhone(String profileId, String? phoneE164) async {
    await (update(localProfiles)..where((p) => p.id.equals(profileId))).write(
      LocalProfilesCompanion(
        phoneE164: Value(phoneE164),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
