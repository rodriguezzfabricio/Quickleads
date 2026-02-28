import 'package:drift/drift.dart';

/// Local mirror of `public.call_logs` in Postgres.
class LocalCallLogs extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get leadId => text().nullable()();
  TextColumn get phoneE164 => text()();
  TextColumn get platform => text()(); // 'android' | 'ios' | 'unknown'
  TextColumn get source => text()(); // 'native_observer' | 'resume_prompt' | etc.
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationSec =>
      integer().withDefault(const Constant(0))();
  TextColumn get disposition =>
      text().withDefault(const Constant('unknown'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  // ── Local sync tracking ───────────────────────────────────────────
  BoolColumn get needsSync =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
