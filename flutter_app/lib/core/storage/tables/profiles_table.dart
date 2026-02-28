import 'package:drift/drift.dart';

/// Local cache of `public.profiles` in Postgres.
///
/// Cached locally so profile info (name, role) is available offline.
class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get authUserId => text()();
  TextColumn get fullName => text().withLength(min: 1, max: 120)();
  TextColumn get role => text().withDefault(const Constant('owner'))();
  TextColumn get phoneE164 => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  // ── Local sync tracking ───────────────────────────────────────────
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
