import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../storage/app_database.dart';

const _uuid = Uuid();
const _localIdentifierCursorKey = '_device_local_identifier';
const _serverDeviceIdCursorKey = '_device_server_id';

/// Manages per-device identity and server-side `devices` registration.
class DeviceRegistrationService {
  DeviceRegistrationService({
    required AppDatabase db,
    required SupabaseClient supabaseClient,
  })  : _db = db,
        _supabaseClient = supabaseClient;

  final AppDatabase _db;
  final SupabaseClient _supabaseClient;

  Future<String?> readRegisteredServerDeviceId() {
    return _readCursor(_serverDeviceIdCursorKey);
  }

  Future<String?> ensureRegisteredForCurrentSession() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    final profileResponse = await _supabaseClient
        .from('profiles')
        .select('id, organization_id')
        .eq('auth_user_id', currentUser.id)
        .maybeSingle();
    if (profileResponse == null) {
      return null;
    }

    final profileId = profileResponse['id'] as String?;
    final organizationId = profileResponse['organization_id'] as String?;
    if (profileId == null || organizationId == null) {
      return null;
    }

    final localIdentifier = await _readOrCreateLocalIdentifier();
    final platform = _platformForRegistration();

    final upserted = await _supabaseClient
        .from('devices')
        .upsert(
          {
            'organization_id': organizationId,
            'profile_id': profileId,
            'device_identifier': localIdentifier,
            'platform': platform,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'organization_id,device_identifier',
        )
        .select('id')
        .single();

    final serverDeviceId = upserted['id'] as String?;
    if (serverDeviceId == null || serverDeviceId.isEmpty) {
      return null;
    }

    await _writeCursor(_serverDeviceIdCursorKey, serverDeviceId);
    return serverDeviceId;
  }

  Future<String> _readOrCreateLocalIdentifier() async {
    final existing = await _readCursor(_localIdentifierCursorKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _uuid.v4();
    await _writeCursor(_localIdentifierCursorKey, generated);
    return generated;
  }

  Future<String?> _readCursor(String key) async {
    final row = await (_db.select(_db.syncCursors)
          ..where((c) => c.entityType.equals(key)))
        .getSingleOrNull();
    return row?.cursor;
  }

  Future<void> _writeCursor(String key, String value) {
    return _db.into(_db.syncCursors).insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            entityType: key,
            cursor: value,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  String _platformForRegistration() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    }
    return 'ios';
  }
}
