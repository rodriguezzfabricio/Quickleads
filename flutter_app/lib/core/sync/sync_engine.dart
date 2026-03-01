import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../storage/app_database.dart';
import 'device_registration_service.dart';
import 'sync_status.dart';

/// Push/pull sync orchestrator.
///
/// Listens to connectivity changes and app lifecycle. When online,
/// pushes pending outbox mutations to [sync-push] Edge Function,
/// then pulls server changes via [sync-pull] Edge Function.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.supabaseClient,
    required this.deviceRegistrationService,
  });

  final AppDatabase db;
  final SupabaseClient supabaseClient;
  final DeviceRegistrationService deviceRegistrationService;

  final _statusController = StreamController<SyncStatus>.broadcast();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _isSyncing = false;

  /// Stream of sync status for UI indicators.
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Current status (last emitted value).
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  // ── Lifecycle ────────────────────────────────────────────────────

  /// Start listening to connectivity changes and schedule periodic sync.
  void startListening() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Periodic sync every 5 minutes when online.
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncNow(),
    );

    // Do an initial sync attempt.
    syncNow();
  }

  /// Stop listening and cancel timers.
  void dispose() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    _statusController.close();
  }

  // ── Manual Trigger ───────────────────────────────────────────────

  /// Trigger a full sync cycle (push then pull). Safe to call anytime.
  Future<SyncResult> syncNow() async {
    if (_isSyncing) return SyncResult.success();

    // Check connectivity first.
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.contains(ConnectivityResult.none)) {
      _emitStatus(SyncStatus.offline);
      return SyncResult.offline();
    }

    _isSyncing = true;
    _emitStatus(SyncStatus.syncing);

    try {
      final pushResult = await _pushPendingMutations();
      final pullResult = await _pullServerChanges();

      final result = SyncResult.success(
        pushedCount: pushResult.pushedCount,
        pulledCount: pullResult.pulledCount,
        conflictCount: pushResult.conflictCount,
      );

      _emitStatus(SyncStatus.idle);
      return result;
    } catch (e) {
      debugPrint('SyncEngine error: $e');
      _emitStatus(SyncStatus.error);
      return SyncResult.error(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  // ── Push ─────────────────────────────────────────────────────────

  /// Push all pending outbox mutations to the server.
  Future<SyncResult> _pushPendingMutations() async {
    // Query pending actions, ordered by creation time.
    final pending = await (db.select(db.pendingSyncActions)
          ..where((a) => a.status.equals('pending'))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)])
          ..limit(50))
        .get();

    if (pending.isEmpty) return SyncResult.success();

    final deviceId = await _resolveDeviceId();
    if (deviceId == null || deviceId.isEmpty) {
      await _revertTooPending(pending.map((e) => e.id).toList());
      return SyncResult.error(
        'Could not register this device for sync. Please sign in again.',
      );
    }

    // Mark as in_flight.
    final ids = pending.map((a) => a.id).toList();
    await (db.update(db.pendingSyncActions)..where((a) => a.id.isIn(ids)))
        .write(
      const PendingSyncActionsCompanion(
        status: Value('in_flight'),
      ),
    );

    // Build request payload.
    final mutations = pending.map((a) {
      return {
        'client_mutation_id': a.clientMutationId,
        'entity': a.entityType,
        'entity_id': a.entityId,
        'type': a.mutationType,
        if (a.baseVersion != null) 'base_version': a.baseVersion,
        'payload': jsonDecode(a.payload),
      };
    }).toList();

    try {
      final response = await supabaseClient.functions.invoke(
        'sync-push',
        body: {
          'device_id': deviceId,
          'mutations': mutations,
        },
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null || data['ok'] != true) {
        // Server returned an error — revert to pending for retry.
        await _revertTooPending(ids);
        final errorMsg = data?['error']?['message'] ?? 'Unknown push error';
        return SyncResult.error(errorMsg);
      }

      final applied = List<String>.from(data['data']?['applied'] ?? []);
      final conflicts = List<Map<String, dynamic>>.from(
        data['data']?['conflicts'] ?? [],
      );

      // Mark successfully applied mutations.
      if (applied.isNotEmpty) {
        // Find actions by clientMutationId.
        for (final action in pending) {
          if (applied.contains(action.clientMutationId)) {
            await (db.delete(db.pendingSyncActions)
                  ..where((a) => a.id.equals(action.id)))
                .go();
            // Clear needsSync flag on the entity.
            await _markEntitySynced(action.entityType, action.entityId);
          }
        }
      }

      // Mark conflicts.
      for (final conflict in conflicts) {
        final mutationId = conflict['client_mutation_id'] as String?;
        if (mutationId != null) {
          final action = pending.where(
            (a) => a.clientMutationId == mutationId,
          );
          for (final a in action) {
            await (db.update(db.pendingSyncActions)
                  ..where((row) => row.id.equals(a.id)))
                .write(
              const PendingSyncActionsCompanion(
                status: Value('conflict'),
              ),
            );
          }
        }
      }

      // Update server cursor if provided.
      final serverCursor = data['data']?['server_cursor'] as String?;
      if (serverCursor != null) {
        await _updateCursor('all', serverCursor);
      }

      return SyncResult.success(
        pushedCount: applied.length,
        conflictCount: conflicts.length,
      );
    } catch (e) {
      // Network error — revert to pending for retry.
      await _revertTooPending(ids);
      rethrow;
    }
  }

  // ── Pull ─────────────────────────────────────────────────────────

  /// Pull server changes since our last cursor.
  Future<SyncResult> _pullServerChanges() async {
    final deviceId = await _resolveDeviceId();
    int totalPulled = 0;
    bool hasMore = true;

    while (hasMore) {
      final cursor = await _getCursor('all');

      try {
        final queryParams = <String, String>{
          'limit': '100',
          if (cursor != null) 'cursor': cursor,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        };

        final response = await supabaseClient.functions.invoke(
          'sync-pull',
          method: HttpMethod.get,
          queryParameters: queryParams,
        );

        final data = response.data as Map<String, dynamic>?;

        if (data == null || data['ok'] != true) {
          final errorMsg = data?['error']?['message'] ?? 'Unknown pull error';
          return SyncResult.error(errorMsg);
        }

        final pullData = data['data'] as Map<String, dynamic>;
        final changes = List<Map<String, dynamic>>.from(
          pullData['changes'] ?? [],
        );
        hasMore = pullData['has_more'] == true;
        final nextCursor = pullData['next_cursor'] as String?;

        // Apply each change to local DB.
        for (final change in changes) {
          await _applyServerChange(change);
        }

        totalPulled += changes.length;

        // Store next cursor.
        if (nextCursor != null) {
          await _updateCursor('all', nextCursor);
        }

        if (changes.isEmpty) hasMore = false;
      } catch (e) {
        debugPrint('SyncEngine pull error: $e');
        return SyncResult.error(e.toString());
      }
    }

    return SyncResult.success(pulledCount: totalPulled);
  }

  // ── Server Change Application ───────────────────────────────────

  /// Apply a single server change to the local DB (no outbox entry).
  Future<void> _applyServerChange(Map<String, dynamic> change) async {
    final entityType = change['entity_type'] as String?;
    final dataRaw = change['data'];
    if (entityType == null || dataRaw is! Map) return;

    final data = Map<String, dynamic>.from(dataRaw);
    final syncedAt = DateTime.now();

    switch (entityType) {
      case 'lead':
        await db.into(db.localLeads).insertOnConflictUpdate(
              LocalLeadsCompanion(
                id: Value(_requiredString(data, 'id')),
                organizationId: Value(_requiredString(data, 'organization_id')),
                createdByProfileId:
                    Value(_optionalString(data, 'created_by_profile_id')),
                clientName: Value(_requiredString(data, 'client_name')),
                phoneE164: Value(_optionalString(data, 'phone_e164')),
                email: Value(_optionalString(data, 'email')),
                jobType: Value(_requiredString(data, 'job_type')),
                notes: Value(_optionalString(data, 'notes')),
                status: Value(_requiredString(data, 'status')),
                followupState: Value(_requiredString(data, 'followup_state')),
                estimateSentAt:
                    Value(_optionalDateTime(data, 'estimate_sent_at')),
                version: Value(_requiredInt(data, 'version')),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                deletedAt: Value(_optionalDateTime(data, 'deleted_at')),
                needsSync: const Value(false),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'job':
        await db.into(db.localJobs).insertOnConflictUpdate(
              LocalJobsCompanion(
                id: Value(_requiredString(data, 'id')),
                organizationId: Value(_requiredString(data, 'organization_id')),
                leadId: Value(_optionalString(data, 'lead_id')),
                clientName: Value(_requiredString(data, 'client_name')),
                jobType: Value(_requiredString(data, 'job_type')),
                phase: Value(_requiredString(data, 'phase')),
                healthStatus: Value(_requiredString(data, 'health_status')),
                estimatedCompletionDate:
                    Value(_optionalDateTime(data, 'estimated_completion_date')),
                version: Value(_requiredInt(data, 'version')),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                deletedAt: Value(_optionalDateTime(data, 'deleted_at')),
                needsSync: const Value(false),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'followup_sequence':
        await db.into(db.localFollowupSequences).insertOnConflictUpdate(
              LocalFollowupSequencesCompanion(
                id: Value(_requiredString(data, 'id')),
                organizationId: Value(_requiredString(data, 'organization_id')),
                leadId: Value(_requiredString(data, 'lead_id')),
                state: Value(_requiredString(data, 'state')),
                startDateLocal:
                    Value(_requiredDateTime(data, 'start_date_local')),
                timezone: Value(_requiredString(data, 'timezone')),
                nextSendAt: Value(_optionalDateTime(data, 'next_send_at')),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                pausedAt: Value(_optionalDateTime(data, 'paused_at')),
                stoppedAt: Value(_optionalDateTime(data, 'stopped_at')),
                completedAt: Value(_optionalDateTime(data, 'completed_at')),
                needsSync: const Value(false),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'followup_message':
        await db.into(db.localFollowupMessages).insertOnConflictUpdate(
              LocalFollowupMessagesCompanion(
                id: Value(_requiredString(data, 'id')),
                sequenceId: Value(_requiredString(data, 'sequence_id')),
                stepNumber: Value(_requiredInt(data, 'step_number')),
                channel: Value(_requiredString(data, 'channel')),
                templateKey: Value(_requiredString(data, 'template_key')),
                scheduledAt: Value(_requiredDateTime(data, 'scheduled_at')),
                sentAt: Value(_optionalDateTime(data, 'sent_at')),
                status: Value(_requiredString(data, 'status')),
                retryCount: Value(_optionalInt(data, 'retry_count') ?? 0),
                providerMessageId:
                    Value(_optionalString(data, 'provider_message_id')),
                errorMessage: Value(_optionalString(data, 'error_message')),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                needsSync: const Value(false),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'call_log':
        await db.into(db.localCallLogs).insertOnConflictUpdate(
              LocalCallLogsCompanion(
                id: Value(_requiredString(data, 'id')),
                organizationId: Value(_requiredString(data, 'organization_id')),
                leadId: Value(_optionalString(data, 'lead_id')),
                phoneE164: Value(_requiredString(data, 'phone_e164')),
                platform: Value(_requiredString(data, 'platform')),
                source: Value(_requiredString(data, 'source')),
                startedAt: Value(_requiredDateTime(data, 'started_at')),
                durationSec: Value(_optionalInt(data, 'duration_sec') ?? 0),
                disposition:
                    Value(_optionalString(data, 'disposition') ?? 'unknown'),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                needsSync: const Value(false),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'message_template':
        await db.into(db.localMessageTemplates).insertOnConflictUpdate(
              LocalMessageTemplatesCompanion(
                id: Value(_requiredString(data, 'id')),
                organizationId: Value(_requiredString(data, 'organization_id')),
                templateKey: Value(_requiredString(data, 'template_key')),
                smsBody: Value(_requiredString(data, 'sms_body')),
                emailSubject: Value(_optionalString(data, 'email_subject')),
                emailBody: Value(_optionalString(data, 'email_body')),
                active: Value(_optionalBool(data, 'active') ?? true),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                needsSync: const Value(false),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'organization':
        await db.into(db.localOrganizations).insertOnConflictUpdate(
              LocalOrganizationsCompanion(
                id: Value(_requiredString(data, 'id')),
                name: Value(_requiredString(data, 'name')),
                timezone: Value(_requiredString(data, 'timezone')),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
      case 'profile':
        await db.into(db.localProfiles).insertOnConflictUpdate(
              LocalProfilesCompanion(
                id: Value(_requiredString(data, 'id')),
                organizationId: Value(_requiredString(data, 'organization_id')),
                authUserId: Value(_requiredString(data, 'auth_user_id')),
                fullName: Value(_requiredString(data, 'full_name')),
                role: Value(_requiredString(data, 'role')),
                phoneE164: Value(_optionalString(data, 'phone_e164')),
                createdAt: Value(_requiredDateTime(data, 'created_at')),
                updatedAt: Value(_requiredDateTime(data, 'updated_at')),
                lastSyncedAt: Value(syncedAt),
              ),
            );
        break;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) return value;
    throw StateError('Expected string for key "$key" in sync payload.');
  }

  String? _optionalString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is String) return value;
    throw StateError(
        'Expected nullable string for key "$key" in sync payload.');
  }

  int _requiredInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw StateError('Expected int for key "$key" in sync payload.');
  }

  int? _optionalInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    throw StateError('Expected nullable int for key "$key" in sync payload.');
  }

  bool? _optionalBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    throw StateError('Expected nullable bool for key "$key" in sync payload.');
  }

  DateTime _requiredDateTime(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) return DateTime.parse(value);
    throw StateError(
        'Expected ISO datetime string for key "$key" in sync payload.');
  }

  DateTime? _optionalDateTime(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is String) return DateTime.parse(value);
    throw StateError(
        'Expected nullable ISO datetime string for key "$key" in sync payload.');
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _emitStatus(SyncStatus.offline);
    } else {
      // Connectivity restored — trigger sync.
      syncNow();
    }
  }

  void _emitStatus(SyncStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> _revertTooPending(List<String> ids) async {
    // Use customStatement for the retry_count increment since Drift's
    // companion can't express column + 1 directly.
    await db.customStatement(
      'UPDATE pending_sync_actions '
      'SET status = \'pending\', retry_count = retry_count + 1 '
      'WHERE id IN (${List.filled(ids.length, '?').join(', ')})',
      ids,
    );
  }

  Future<void> _markEntitySynced(
    String entityType,
    String? entityId,
  ) async {
    if (entityId == null) return;
    final now = DateTime.now();

    switch (entityType) {
      case 'lead':
        await (db.update(db.localLeads)..where((l) => l.id.equals(entityId)))
            .write(LocalLeadsCompanion(
          needsSync: const Value(false),
          lastSyncedAt: Value(now),
        ));
        break;
      case 'job':
        await (db.update(db.localJobs)..where((j) => j.id.equals(entityId)))
            .write(LocalJobsCompanion(
          needsSync: const Value(false),
          lastSyncedAt: Value(now),
        ));
        break;
      case 'followup_sequence':
        await (db.update(db.localFollowupSequences)
              ..where((s) => s.id.equals(entityId)))
            .write(LocalFollowupSequencesCompanion(
          needsSync: const Value(false),
          lastSyncedAt: Value(now),
        ));
        break;
      case 'call_log':
        await (db.update(db.localCallLogs)..where((c) => c.id.equals(entityId)))
            .write(LocalCallLogsCompanion(
          needsSync: const Value(false),
          lastSyncedAt: Value(now),
        ));
        break;
      case 'message_template':
        await (db.update(db.localMessageTemplates)
              ..where((t) => t.id.equals(entityId)))
            .write(
          LocalMessageTemplatesCompanion(
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
        );
        break;
    }
  }

  Future<String?> _getCursor(String entityType) async {
    final row = await (db.select(db.syncCursors)
          ..where((c) => c.entityType.equals(entityType)))
        .getSingleOrNull();
    return row?.cursor;
  }

  Future<void> _updateCursor(String entityType, String cursor) async {
    await db.into(db.syncCursors).insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            entityType: entityType,
            cursor: cursor,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<String?> _resolveDeviceId() async {
    final existing =
        await deviceRegistrationService.readRegisteredServerDeviceId();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    return deviceRegistrationService.ensureRegisteredForCurrentSession();
  }
}
