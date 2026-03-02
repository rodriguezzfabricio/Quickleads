// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_photos_dao.dart';

// ignore_for_file: type=lint
mixin _$JobPhotosDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalJobPhotosTable get localJobPhotos => attachedDatabase.localJobPhotos;
  JobPhotosDaoManager get managers => JobPhotosDaoManager(this);
}

class JobPhotosDaoManager {
  final _$JobPhotosDaoMixin _db;
  JobPhotosDaoManager(this._db);
  $$LocalJobPhotosTableTableManager get localJobPhotos =>
      $$LocalJobPhotosTableTableManager(
          _db.attachedDatabase, _db.localJobPhotos);
}
