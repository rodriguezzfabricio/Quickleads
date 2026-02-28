import 'package:drift/drift.dart';

/// Local mirror of `public.followup_messages` in Postgres.
class LocalFollowupMessages extends Table {
  TextColumn get id => text()();
  TextColumn get sequenceId => text()();
  IntColumn get stepNumber => integer()();
  TextColumn get channel => text()(); // 'sms' | 'email'
  TextColumn get templateKey => text().withLength(min: 1, max: 100)();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('queued'))();
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();
  TextColumn get providerMessageId => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  // ── Local sync tracking ───────────────────────────────────────────
  BoolColumn get needsSync =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
