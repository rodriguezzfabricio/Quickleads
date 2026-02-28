import 'package:drift/drift.dart';

/// Local mirror of `public.jobs` in Postgres.
class LocalJobs extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get leadId => text().nullable()();
  TextColumn get clientName => text().withLength(min: 1, max: 120)();
  TextColumn get jobType => text().withLength(min: 1, max: 80)();
  TextColumn get phase => text().withDefault(const Constant('demo'))();
  TextColumn get healthStatus =>
      text().withDefault(const Constant('green'))();
  DateTimeColumn get estimatedCompletionDate => dateTime().nullable()();
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
