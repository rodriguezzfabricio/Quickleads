import 'package:drift/drift.dart';

/// Local mirror of `public.leads` in Postgres.
///
/// UUIDs are stored as text (SQLite has no native UUID type).
/// [needsSync] / [lastSyncedAt] are local-only sync tracking fields.
class LocalLeads extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get createdByProfileId => text().nullable()();
  TextColumn get clientName => text().withLength(min: 1, max: 120)();
  TextColumn get phoneE164 => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get jobType => text().withLength(min: 1, max: 80)();
  TextColumn get notes => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('new_callback'))();
  TextColumn get followupState =>
      text().withDefault(const Constant('none'))();
  DateTimeColumn get estimateSentAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // ── Local sync tracking ───────────────────────────────────────────
  BoolColumn get needsSync =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
