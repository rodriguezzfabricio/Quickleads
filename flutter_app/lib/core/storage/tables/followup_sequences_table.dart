import 'package:drift/drift.dart';

/// Local mirror of `public.followup_sequences` in Postgres.
class LocalFollowupSequences extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get leadId => text()();
  TextColumn get state =>
      text().withDefault(const Constant('active'))();
  DateTimeColumn get startDateLocal => dateTime()();
  TextColumn get timezone => text().withLength(min: 1, max: 100)();
  DateTimeColumn get nextSendAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get stoppedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // ── Local sync tracking ───────────────────────────────────────────
  BoolColumn get needsSync =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
