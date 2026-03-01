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

  test(
      'markEstimateSent updates lead, creates sequence, and schedules notifications',
      () async {
    await db.organizationsDao.upsertOrganization(
      LocalOrganizationsCompanion.insert(
        id: 'org-1',
        name: 'CrewCommand',
        timezone: const Value('America/New_York'),
      ),
    );
    await db.leadsDao.createLead(
      LocalLeadsCompanion.insert(
        id: 'lead-1',
        organizationId: 'org-1',
        clientName: 'Client 1',
        jobType: 'Kitchen',
      ),
    );

    final initialLead = await db.leadsDao.getLeadById('lead-1');
    expect(initialLead, isNotNull);

    await leadActionsService.markEstimateSent(initialLead!);

    final updatedLead = await db.leadsDao.getLeadById('lead-1');
    expect(updatedLead, isNotNull);
    expect(updatedLead!.status, 'estimate_sent');
    expect(updatedLead.followupState, 'active');
    expect(updatedLead.estimateSentAt, isNotNull);

    final sequence = await db.followupsDao.getSequenceByLeadId('lead-1');
    expect(sequence, isNotNull);
    expect(sequence!.state, 'active');

    expect(scheduler.scheduleCalls, 1);
    expect(scheduler.cancelCalls, 0);
  });

  test('updateFollowupState paused updates sequence and cancels notifications',
      () async {
    await db.organizationsDao.upsertOrganization(
      LocalOrganizationsCompanion.insert(
        id: 'org-2',
        name: 'CrewCommand',
        timezone: const Value('America/New_York'),
      ),
    );
    await db.leadsDao.createLead(
      LocalLeadsCompanion.insert(
        id: 'lead-2',
        organizationId: 'org-2',
        clientName: 'Client 2',
        jobType: 'Bath',
      ),
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
}
