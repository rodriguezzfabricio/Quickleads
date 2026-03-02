import 'package:drift/drift.dart';

/// Local mirror for job photos, including offline file path while pending upload.
class LocalJobPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text()();
  TextColumn get organizationId => text()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get localFilePath => text().nullable()();
  TextColumn get takenAtSource => text().nullable()();
  DateTimeColumn get uploadedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Local sync tracking.
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
