import 'package:drift/drift.dart';

/// Tracks the last sync position per entity type.
///
/// The [cursor] stores an ISO-8601 timestamp from the server.
/// On each pull, we send this cursor to get only changes since
/// our last sync.
class SyncCursors extends Table {
  TextColumn get entityType => text()();
  TextColumn get cursor => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {entityType};
}
