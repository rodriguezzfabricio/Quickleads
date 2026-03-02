import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:crewcommand_mobile/core/notifications/notification_service.dart';
import 'package:crewcommand_mobile/core/services/lead_actions_service.dart';
import 'package:crewcommand_mobile/core/storage/app_database.dart';

class _FakeNotificationScheduler implements FollowupNotificationScheduler {
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> cancelFollowUpNotifications({required String leadId}) async {
    cancelCalls += 1;
  }

  @override
  Future<void> scheduleFollowUpNotifications({
    required String leadId,
    required String clientName,
    required DateTime estimateSentAt,
  }) async {
    scheduleCalls += 1;
  }
}

void main() {
  late AppDatabase db;
  late DriftLeadActionsService leadActionsService;
  late _FakeNotificationScheduler scheduler;

  setUp(() {
    db = AppDatabase.memory();
    scheduler = _FakeNotificationScheduler();
    leadActionsService = DriftLeadActionsService(
      leadsDao: db.leadsDao,
      followupsDao: db.followupsDao,
      organizationsDao: db.organizationsDao,
      notificationScheduler: scheduler,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedLead({
    required String orgId,
    required String leadId,
    required String clientName,
    required String jobType,
  }) async {
    await db.organizationsDao.upsertOrganization(
      LocalOrganizationsCompanion.insert(
        id: orgId,
        name: 'CrewCommand',
        timezone: const Value('America/New_York'),
      ),
    );
    await db.leadsDao.createLead(
      LocalLeadsCompanion.insert(
        id: leadId,
        organizationId: orgId,
        clientName: clientName,
        jobType: jobType,
      ),
    );
  }

  test(
      'markEstimateSent updates lead, creates sequence, and schedules notifications',
      () async {
    await seedLead(
      orgId: 'org-1',
      leadId: 'lead-1',
      clientName: 'Client 1',
      jobType: 'Kitchen',
    );

    final initialLead = await db.leadsDao.getLeadById('lead-1');
    expect(initialLead, isNotNull);

    final result = await leadActionsService.markEstimateSent(initialLead!);

    final updatedLead = await db.leadsDao.getLeadById('lead-1');
    expect(updatedLead, isNotNull);
    expect(updatedLead!.status, 'estimate_sent');
    expect(updatedLead.followupState, 'active');
    expect(updatedLead.estimateSentAt, isNotNull);
    expect(result.persistence, EstimateSentPersistence.queuedLocally);
    expect(result.serverReconciled, isFalse);

    final sequence = await db.followupsDao.getSequenceByLeadId('lead-1');
    expect(sequence, isNotNull);
    expect(sequence!.state, 'active');

    expect(scheduler.scheduleCalls, 1);
    expect(scheduler.cancelCalls, 0);
  });

  test('updateFollowupState paused updates sequence and cancels notifications',
      () async {
    await seedLead(
      orgId: 'org-2',
      leadId: 'lead-2',
      clientName: 'Client 2',
      jobType: 'Bath',
    );

    var lead = await db.leadsDao.getLeadById('lead-2');
    await leadActionsService.markEstimateSent(lead!);

    lead = await db.leadsDao.getLeadById('lead-2');
    await leadActionsService.updateFollowupState(
      lead: lead!,
      nextState: 'paused',
    );

    final updatedLead = await db.leadsDao.getLeadById('lead-2');
    final sequence = await db.followupsDao.getSequenceByLeadId('lead-2');
    expect(updatedLead, isNotNull);
    expect(updatedLead!.followupState, 'paused');
    expect(sequence, isNotNull);
    expect(sequence!.state, 'paused');
    expect(scheduler.cancelCalls, 1);
  });

  test('recoverable server failure falls back locally and queues reconcile',
      () async {
    await seedLead(
      orgId: 'org-3',
      leadId: 'lead-3',
      clientName: 'Client 3',
      jobType: 'Roofing',
    );

    var remoteCalls = 0;
    var syncCalls = 0;
    final fallbackService = DriftLeadActionsService(
      leadsDao: db.leadsDao,
      followupsDao: db.followupsDao,
      organizationsDao: db.organizationsDao,
      notificationScheduler: scheduler,
      remoteMarkEstimateSent: (
        _, {
        required String triggerSource,
        DateTime? estimateSentAtOverride,
      }) async {
        remoteCalls += 1;
        throw Exception(
          'FunctionException(status: 404, details: {ok: false, error: {code: not_found, message: Lead was not found in the authenticated organization.}})',
        );
      },
      syncNowOverride: () async {
        syncCalls += 1;
      },
    );

    final lead = await db.leadsDao.getLeadById('lead-3');
    final result = await fallbackService.markEstimateSent(lead!);

    final updatedLead = await db.leadsDao.getLeadById('lead-3');
    final sequence = await db.followupsDao.getSequenceByLeadId('lead-3');
    expect(updatedLead, isNotNull);
    expect(updatedLead!.status, 'estimate_sent');
    expect(updatedLead.followupState, 'active');
    expect(sequence, isNotNull);
    expect(scheduler.scheduleCalls, 1);

    expect(result.persistence, EstimateSentPersistence.queuedLocally);
    expect(result.serverReconciled, isFalse);
    expect(remoteCalls, 2);
    expect(syncCalls, 2);
  });

  test('unrecoverable server failure rethrows and does not fallback', () async {
    await seedLead(
      orgId: 'org-4',
      leadId: 'lead-4',
      clientName: 'Client 4',
      jobType: 'HVAC',
    );

    final conflictService = DriftLeadActionsService(
      leadsDao: db.leadsDao,
      followupsDao: db.followupsDao,
      organizationsDao: db.organizationsDao,
      notificationScheduler: scheduler,
      remoteMarkEstimateSent: (
        _, {
        required String triggerSource,
        DateTime? estimateSentAtOverride,
      }) async {
        throw Exception(
          'FunctionException(status: 409, details: {ok: false, error: {code: conflict, message: Cannot mark estimate sent for terminal lead status.}})',
        );
      },
      syncNowOverride: () async {},
    );

    final lead = await db.leadsDao.getLeadById('lead-4');
    await expectLater(
      conflictService.markEstimateSent(lead!),
      throwsA(isA<Exception>()),
    );

    final unchangedLead = await db.leadsDao.getLeadById('lead-4');
    final sequence = await db.followupsDao.getSequenceByLeadId('lead-4');
    expect(unchangedLead, isNotNull);
    expect(unchangedLead!.status, 'new_callback');
    expect(sequence, isNull);
    expect(scheduler.scheduleCalls, 0);
  });
}
