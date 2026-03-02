import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../notifications/notification_service.dart';
import '../storage/app_database.dart';
import '../storage/daos/followups_dao.dart';
import '../storage/daos/leads_dao.dart';
import '../storage/daos/organizations_dao.dart';
import '../sync/sync_engine.dart';

const _uuid = Uuid();

enum EstimateSentPersistence {
  serverApplied,
  queuedLocally,
}

class MarkEstimateSentResult {
  const MarkEstimateSentResult({
    required this.persistence,
    required this.estimateSentAt,
    required this.serverReconciled,
  });

  final EstimateSentPersistence persistence;
  final DateTime estimateSentAt;
  final bool serverReconciled;
}

typedef MarkEstimateSentRemoteInvoker = Future<DateTime> Function(
  LocalLead lead, {
  required String triggerSource,
  DateTime? estimateSentAtOverride,
});

/// Shared lead action interface used by Home, Leads, and Lead Detail screens.
abstract class LeadActionsService {
  Future<MarkEstimateSentResult> markEstimateSent(
    LocalLead lead, {
    String triggerSource,
  });

  Future<void> updateFollowupState({
    required LocalLead lead,
    required String nextState,
  });
}

class DriftLeadActionsService implements LeadActionsService {
  DriftLeadActionsService({
    required LeadsDao leadsDao,
    required FollowupsDao followupsDao,
    required OrganizationsDao organizationsDao,
    required FollowupNotificationScheduler notificationScheduler,
    SupabaseClient? supabaseClient,
    SyncEngine? syncEngine,
    MarkEstimateSentRemoteInvoker? remoteMarkEstimateSent,
    Future<dynamic> Function()? syncNowOverride,
  })  : _leadsDao = leadsDao,
        _followupsDao = followupsDao,
        _organizationsDao = organizationsDao,
        _notificationScheduler = notificationScheduler,
        _supabaseClient = supabaseClient,
        _syncEngine = syncEngine,
        _remoteMarkEstimateSent = remoteMarkEstimateSent,
        _syncNowOverride = syncNowOverride;

  final LeadsDao _leadsDao;
  final FollowupsDao _followupsDao;
  final OrganizationsDao _organizationsDao;
  final FollowupNotificationScheduler _notificationScheduler;
  final SupabaseClient? _supabaseClient;
  final SyncEngine? _syncEngine;
  final MarkEstimateSentRemoteInvoker? _remoteMarkEstimateSent;
  final Future<dynamic> Function()? _syncNowOverride;

  @override
  Future<MarkEstimateSentResult> markEstimateSent(
    LocalLead lead, {
    String triggerSource = 'manual',
  }) async {
    final normalizedTrigger =
        triggerSource == 'sent_from_another_tool' ? triggerSource : 'manual';

    if (_hasRemotePath) {
      await _bestEffortSyncNow();
      try {
        final estimateSentAt = await _invokeRemoteMarkEstimateSent(
          lead,
          triggerSource: normalizedTrigger,
        );
        await _bestEffortSyncNow();
        await _notificationScheduler.scheduleFollowUpNotifications(
          leadId: lead.id,
          clientName: lead.clientName,
          estimateSentAt: estimateSentAt,
        );
        return MarkEstimateSentResult(
          persistence: EstimateSentPersistence.serverApplied,
          estimateSentAt: estimateSentAt,
          serverReconciled: true,
        );
      } catch (error) {
        if (!_isRecoverableServerFailure(error)) {
          rethrow;
        }

        final estimateSentAt = DateTime.now();
        await _applyLocalEstimateSent(
          lead,
          estimateSentAt: estimateSentAt,
        );
        await _notificationScheduler.scheduleFollowUpNotifications(
          leadId: lead.id,
          clientName: lead.clientName,
          estimateSentAt: estimateSentAt,
        );
        final serverReconciled = await _bestEffortReconcileOnServer(
          lead,
          triggerSource: normalizedTrigger,
          estimateSentAt: estimateSentAt,
        );
        return MarkEstimateSentResult(
          persistence: EstimateSentPersistence.queuedLocally,
          estimateSentAt: estimateSentAt,
          serverReconciled: serverReconciled,
        );
      }
    }

    final estimateSentAt = DateTime.now();
    await _applyLocalEstimateSent(
      lead,
      estimateSentAt: estimateSentAt,
    );
    await _notificationScheduler.scheduleFollowUpNotifications(
      leadId: lead.id,
      clientName: lead.clientName,
      estimateSentAt: estimateSentAt,
    );
    return MarkEstimateSentResult(
      persistence: EstimateSentPersistence.queuedLocally,
      estimateSentAt: estimateSentAt,
      serverReconciled: false,
    );
  }

  @override
  Future<void> updateFollowupState({
    required LocalLead lead,
    required String nextState,
  }) async {
    await _leadsDao.updateFollowupState(
      lead.id,
      nextState,
      lead.version,
    );

    final existingSequence = await _followupsDao.getSequenceByLeadId(lead.id);

    if (existingSequence == null && nextState == 'active') {
      await _ensureSequence(
        lead: lead,
        state: 'active',
        anchorDate: lead.estimateSentAt ?? DateTime.now(),
      );
    } else if (existingSequence != null) {
      await _followupsDao.updateSequenceState(existingSequence.id, nextState);
    }

    if (nextState == 'paused' ||
        nextState == 'stopped' ||
        nextState == 'completed') {
      await _notificationScheduler.cancelFollowUpNotifications(leadId: lead.id);
    } else if (nextState == 'active' && lead.estimateSentAt != null) {
      await _notificationScheduler.scheduleFollowUpNotifications(
        leadId: lead.id,
        clientName: lead.clientName,
        estimateSentAt: lead.estimateSentAt!,
      );
    }

    await _syncEngine?.syncNow();
  }

  Future<DateTime> _markEstimateSentOnServer(
    LocalLead lead, {
    required String triggerSource,
    DateTime? estimateSentAtOverride,
  }) async {
    final body = <String, dynamic>{
      'lead_id': lead.id,
      'trigger_source': triggerSource,
    };
    if (estimateSentAtOverride != null) {
      body['estimate_sent_at'] = estimateSentAtOverride.toIso8601String();
    }

    final response = await _supabaseClient!.functions.invoke(
      'leads-estimate-sent',
      body: body,
    );

    final payload = response.data;
    if (payload is! Map) {
      throw StateError('Invalid leads-estimate-sent response payload.');
    }

    final payloadMap = Map<String, dynamic>.from(payload);
    if (payloadMap['ok'] != true) {
      final error = payloadMap['error'];
      if (error is Map && error['message'] is String) {
        throw Exception(error['message'] as String);
      }
      throw Exception('leads-estimate-sent failed.');
    }

    final data = payloadMap['data'];
    if (data is! Map) {
      throw StateError('leads-estimate-sent did not return data payload.');
    }

    final dataMap = Map<String, dynamic>.from(data);
    final estimateSentAtRaw = dataMap['estimate_sent_at'];
    if (estimateSentAtRaw is! String) {
      throw StateError(
        'leads-estimate-sent returned an invalid estimate_sent_at field.',
      );
    }

    return DateTime.parse(estimateSentAtRaw);
  }

  bool get _hasRemotePath {
    return _remoteMarkEstimateSent != null || _supabaseClient != null;
  }

  Future<void> _applyLocalEstimateSent(
    LocalLead lead, {
    required DateTime estimateSentAt,
  }) async {
    final latestLead = await _leadsDao.getLeadById(lead.id) ?? lead;
    await _leadsDao.markEstimateSent(
      latestLead.id,
      latestLead.version,
      estimateSentAt: estimateSentAt,
    );

    await _ensureSequence(
      lead: latestLead,
      state: 'active',
      anchorDate: estimateSentAt,
    );
  }

  Future<DateTime> _invokeRemoteMarkEstimateSent(
    LocalLead lead, {
    required String triggerSource,
    DateTime? estimateSentAtOverride,
  }) async {
    final remoteInvoker = _remoteMarkEstimateSent;
    if (remoteInvoker != null) {
      return remoteInvoker(
        lead,
        triggerSource: triggerSource,
        estimateSentAtOverride: estimateSentAtOverride,
      );
    }
    return _markEstimateSentOnServer(
      lead,
      triggerSource: triggerSource,
      estimateSentAtOverride: estimateSentAtOverride,
    );
  }

  Future<void> _bestEffortSyncNow() async {
    final sync = _syncNowOverride ?? _syncEngine?.syncNow;
    if (sync == null) {
      return;
    }
    try {
      await sync();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('LeadActionsService sync attempt failed: $error');
      }
    }
  }

  Future<bool> _bestEffortReconcileOnServer(
    LocalLead lead, {
    required String triggerSource,
    required DateTime estimateSentAt,
  }) async {
    if (!_hasRemotePath) {
      return false;
    }

    await _bestEffortSyncNow();
    try {
      await _invokeRemoteMarkEstimateSent(
        lead,
        triggerSource: triggerSource,
        estimateSentAtOverride: estimateSentAt,
      );
      await _bestEffortSyncNow();
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('LeadActionsService reconcile attempt failed: $error');
      }
      return false;
    }
  }

  bool _isRecoverableServerFailure(Object error) {
    final raw = error.toString().toLowerCase();
    if (_containsTransportFailure(raw)) {
      return true;
    }

    if (error is FunctionException) {
      if (error.status == 404) {
        return true;
      }

      final details = error.details;
      if (details is Map) {
        final detailsMap = Map<String, dynamic>.from(
          details.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
        final codeRaw = detailsMap['error'];
        if (codeRaw is Map) {
          final code = codeRaw['code']?.toString().toLowerCase() ?? '';
          if (code == 'not_found') {
            return true;
          }
        }
      }
    }

    return raw.contains('not_found') || raw.contains('lead was not found');
  }

  bool _containsTransportFailure(String raw) {
    return raw.contains('socketexception') ||
        raw.contains('clientexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('connection refused') ||
        raw.contains('connection reset') ||
        raw.contains('network is unreachable') ||
        raw.contains('timed out') ||
        raw.contains('timeout') ||
        raw.contains('offline') ||
        raw.contains('unable to resolve host');
  }

  Future<void> _ensureSequence({
    required LocalLead lead,
    required String state,
    required DateTime anchorDate,
  }) async {
    final existing = await _followupsDao.getSequenceByLeadId(lead.id);
    if (existing != null) {
      if (existing.state != state) {
        await _followupsDao.updateSequenceState(existing.id, state);
      }
      return;
    }

    final organization =
        await _organizationsDao.getOrganization(lead.organizationId);
    final timezone = organization?.timezone ?? 'America/New_York';

    await _followupsDao.createSequence(
      LocalFollowupSequencesCompanion.insert(
        id: _uuid.v5(
          Namespace.url.value,
          'crewcommand/followup-sequence/${lead.organizationId}/${lead.id}',
        ),
        organizationId: lead.organizationId,
        leadId: lead.id,
        state: Value(state),
        startDateLocal: DateTime(
          anchorDate.year,
          anchorDate.month,
          anchorDate.day,
        ),
        timezone: timezone,
      ),
    );
    if (kDebugMode) {
      debugPrint(
          'LeadActionsService: created follow-up sequence for ${lead.id}');
    }
  }
}
