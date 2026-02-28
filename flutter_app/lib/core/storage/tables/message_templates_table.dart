import 'package:drift/drift.dart';

/// Local mirror of `public.message_templates` in Postgres.
class LocalMessageTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get templateKey => text().withLength(min: 1, max: 100)();
  TextColumn get smsBody => text()();
  TextColumn get emailSubject => text().nullable()();
  TextColumn get emailBody => text().nullable()();
  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();
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
