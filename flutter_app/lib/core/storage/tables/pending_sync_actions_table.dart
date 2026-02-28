import 'package:drift/drift.dart';

/// Offline mutation outbox — queues local writes waiting to be pushed.
///
/// Each row represents a single mutation (insert/update/delete) that
/// needs to be sent to the server. The [clientMutationId] serves as
/// an idempotency key so the server can safely handle retries.
///
/// Status flow: pending → in_flight → applied | conflict | failed
class PendingSyncActions extends Table {
  TextColumn get id => text()();
  TextColumn get clientMutationId => text()();
  TextColumn get entityType => text()(); // 'lead' | 'job' | etc.
  TextColumn get entityId => text().nullable()();
  TextColumn get mutationType =>
      text()(); // 'insert' | 'update' | 'delete' | 'status_transition'
  IntColumn get baseVersion => integer().nullable()();
  TextColumn get payload => text()(); // JSON-encoded mutation data
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
