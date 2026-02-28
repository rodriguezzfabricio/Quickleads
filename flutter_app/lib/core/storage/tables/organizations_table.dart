import 'package:drift/drift.dart';

/// Local cache of `public.organizations` in Postgres.
///
/// Cached locally so organization name/timezone is available offline.
class LocalOrganizations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get timezone =>
      text().withDefault(const Constant('America/New_York'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  // ── Local sync tracking ───────────────────────────────────────────
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
