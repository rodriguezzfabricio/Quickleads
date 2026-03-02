import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/job_photos_table.dart';

part 'job_photos_dao.g.dart';

@DriftAccessor(tables: [LocalJobPhotos])
class JobPhotosDao extends DatabaseAccessor<AppDatabase>
    with _$JobPhotosDaoMixin {
  JobPhotosDao(super.db);

  Stream<List<LocalJobPhoto>> watchPhotosByJob(String jobId) {
    return (select(localJobPhotos)
          ..where((p) => p.jobId.equals(jobId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .watch();
  }

  Future<void> addPhoto(LocalJobPhotosCompanion photo) {
    return into(localJobPhotos).insert(photo);
  }

  Future<void> markUploaded(String id, String storagePath) {
    final now = DateTime.now();
    return (update(localJobPhotos)..where((p) => p.id.equals(id))).write(
      LocalJobPhotosCompanion(
        storagePath: Value(storagePath),
        uploadedAt: Value(now),
        needsSync: const Value(false),
        lastSyncedAt: Value(now),
      ),
    );
  }

  Future<void> deletePhoto(String id) {
    return (delete(localJobPhotos)..where((p) => p.id.equals(id))).go();
  }

  Future<List<LocalJobPhoto>> getPendingUploads() {
    return (select(localJobPhotos)
          ..where((p) => p.storagePath.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
        .get();
  }

  Future<void> upsertFromServer(List<LocalJobPhotosCompanion> photos) {
    return batch((b) {
      for (final photo in photos) {
        b.insert(
          localJobPhotos,
          photo.copyWith(
            needsSync: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
