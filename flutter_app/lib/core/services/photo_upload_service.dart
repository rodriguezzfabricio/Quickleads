import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../storage/app_database.dart';
import '../storage/daos/job_photos_dao.dart';

const _uuid = Uuid();

class PhotoUploadService {
  PhotoUploadService({
    required JobPhotosDao jobPhotosDao,
    ImagePicker? imagePicker,
  })  : _jobPhotosDao = jobPhotosDao,
        _imagePicker = imagePicker ?? ImagePicker();

  final JobPhotosDao _jobPhotosDao;
  final ImagePicker _imagePicker;

  Future<File?> pickPhoto({required ImageSource source}) async {
    final picked = await _imagePicker.pickImage(source: source);
    if (picked == null) {
      return null;
    }
    return File(picked.path);
  }

  Future<void> saveJobPhoto({
    required String jobId,
    required String orgId,
    required File file,
  }) async {
    final id = _uuid.v4();
    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docs.path, 'job_photos', orgId, jobId));
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    final extension = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
    final localPath = p.join(photosDir.path, '$id$extension');
    final persisted = await file.copy(localPath);

    await _jobPhotosDao.addPhoto(
      LocalJobPhotosCompanion.insert(
        id: id,
        jobId: jobId,
        organizationId: orgId,
        localFilePath: Value(persisted.path),
      ),
    );
  }

  Future<void> uploadPendingPhotos(SupabaseClient supabase) async {
    final pending = await _jobPhotosDao.getPendingUploads();

    for (final photo in pending) {
      try {
        final path = photo.localFilePath;
        if (path == null || path.trim().isEmpty) {
          continue;
        }

        final localFile = File(path);
        if (!localFile.existsSync()) {
          continue;
        }

        final storagePath = '${photo.organizationId}/${photo.jobId}/${photo.id}.jpg';

        await supabase.storage
            .from('job-photos')
            .upload(
              storagePath,
              localFile,
              fileOptions: const FileOptions(upsert: true),
            );

        await supabase.from('job_photos').upsert(
          {
            'id': photo.id,
            'job_id': photo.jobId,
            'organization_id': photo.organizationId,
            'storage_path': storagePath,
            'taken_at_source': photo.takenAtSource,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'id',
        );

        await _jobPhotosDao.markUploaded(photo.id, storagePath);
      } catch (error) {
        debugPrint('PhotoUploadService upload failed for ${photo.id}: $error');
      }
    }
  }
}
