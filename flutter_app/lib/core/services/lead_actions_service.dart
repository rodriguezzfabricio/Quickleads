import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../notifications/notification_service.dart';
import '../storage/app_database.dart';
import '../storage/daos/followups_dao.dart';
import '../storage/daos/leads_dao.dart';
import '../storage/daos/organizations_dao.dart';

const _uuid = Uuid();

/// Shared lead action interface used by Home, Leads, and Lead Detail screens.
abstract class LeadActionsService {
  Future<void> markEstimateSent(LocalLead lead);

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
  })  : _leadsDao = leadsDao,
        _followupsDao = followupsDao,
        _organizationsDao = organizationsDao,
        _notificationScheduler = notificationScheduler;

  final LeadsDao _leadsDao;
  final FollowupsDao _followupsDao;
  final OrganizationsDao _organizationsDao;
  final FollowupNotificationScheduler _notificationScheduler;

  @override
  Future<void> markEstimateSent(LocalLead lead) async {
    final estimateSentAt = DateTime.now();

    await _leadsDao.markEstimateSent(
      lead.id,
      lead.version,
      estimateSentAt: estimateSentAt,
    );

    await _ensureSequence(
      lead: lead,
      state: 'active',
      anchorDate: estimateSentAt,
    );

    await _notificationScheduler.scheduleFollowUpNotifications(
      leadId: lead.id,
      clientName: lead.clientName,
      estimateSentAt: estimateSentAt,
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
      return;
    }

    if (nextState == 'active' && lead.estimateSentAt != null) {
      await _notificationScheduler.scheduleFollowUpNotifications(
        leadId: lead.id,
        clientName: lead.clientName,
        estimateSentAt: lead.estimateSentAt!,
      );
    }
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
