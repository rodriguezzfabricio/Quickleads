import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:crewcommand_mobile/core/domain/job_health_status.dart';
import 'package:crewcommand_mobile/core/domain/job_phase.dart';
import 'package:crewcommand_mobile/core/storage/app_database.dart';
import 'package:crewcommand_mobile/core/storage/daos/jobs_dao.dart';

void main() {
  late AppDatabase db;
  late JobsDao jobsDao;

  setUp(() {
    db = AppDatabase.memory();
    jobsDao = db.jobsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('JobsDao', () {
    const orgId = 'org-001';

    LocalJobsCompanion makeJob({
      required String id,
      String phase = 'demo',
      String healthStatus = 'green',
      String? leadId,
    }) {
      return LocalJobsCompanion.insert(
        id: id,
        organizationId: orgId,
        clientName: 'Test Client $id',
        jobType: 'Kitchen Remodel',
        leadId: Value(leadId),
        phase: Value(phase),
        healthStatus: Value(healthStatus),
      );
    }

    test('createJob inserts a job and returns it via getJobById', () async {
      await jobsDao.createJob(makeJob(id: 'job-1'));

      final result = await jobsDao.getJobById('job-1');
      expect(result, isNotNull);
      expect(result!.id, 'job-1');
      expect(result.clientName, 'Test Client job-1');
      expect(result.organizationId, orgId);
      expect(result.jobType, 'Kitchen Remodel');
      expect(result.phase, 'demo');
      expect(result.healthStatus, 'green');
      expect(result.needsSync, true);
    });

    test('createJob queues a PendingSyncAction with type=insert', () async {
      await jobsDao.createJob(makeJob(id: 'job-2'));

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(1));
      expect(actions.first.entityType, 'job');
      expect(actions.first.entityId, 'job-2');
      expect(actions.first.mutationType, 'insert');
      expect(actions.first.status, 'pending');
      expect(actions.first.clientMutationId, isNotEmpty);
    });

    test('updateJobPhase changes phase and queues an update sync entry',
        () async {
      await jobsDao.createJob(makeJob(id: 'job-3'));

      await jobsDao.updateJobPhase('job-3', 'rough', 1);

      final job = await jobsDao.getJobById('job-3');
      expect(job!.phase, 'rough');
      expect(job.needsSync, true);

      // 2 outbox entries: insert + phase update.
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(2));
      final updateAction = actions.last;
      expect(updateAction.mutationType, 'update');
      expect(updateAction.baseVersion, 1);

      final payload =
          jsonDecode(updateAction.payload) as Map<String, dynamic>;
      expect(payload['phase'], 'rough');
    });

    test(
        'updateJobHealthStatus changes health status and queues an update sync entry',
        () async {
      await jobsDao.createJob(makeJob(id: 'job-4'));

      await jobsDao.updateJobHealthStatus('job-4', 'yellow', 1);

      final job = await jobsDao.getJobById('job-4');
      expect(job!.healthStatus, 'yellow');
      expect(job.needsSync, true);

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(2));
      final updateAction = actions.last;
      expect(updateAction.mutationType, 'update');

      final payload =
          jsonDecode(updateAction.payload) as Map<String, dynamic>;
      expect(payload['health_status'], 'yellow');
    });

    test('softDeleteJob sets deletedAt and queues a delete sync entry',
        () async {
      await jobsDao.createJob(makeJob(id: 'job-5'));

      await jobsDao.softDeleteJob('job-5', 1);

      final job = await jobsDao.getJobById('job-5');
      expect(job!.deletedAt, isNotNull);
      expect(job.needsSync, true);

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions.last.mutationType, 'delete');

      final payload =
          jsonDecode(actions.last.payload) as Map<String, dynamic>;
      expect(payload['deleted_at'], isNotNull);
    });

    test('watchJobsByOrg excludes soft-deleted jobs', () async {
      await jobsDao.createJob(makeJob(id: 'job-6a'));
      await jobsDao.createJob(makeJob(id: 'job-6b'));
      await jobsDao.softDeleteJob('job-6b', 1);

      final jobs = await jobsDao.watchJobsByOrg(orgId).first;
      final ids = jobs.map((j) => j.id).toList();
      expect(ids, contains('job-6a'));
      expect(ids, isNot(contains('job-6b')));
    });

    test('watchJobsByOrg emits on insert (reactive stream test)', () async {
      // Subscribe before any insert.
      final stream = jobsDao.watchJobsByOrg(orgId);
      final future = stream.first;

      await jobsDao.createJob(makeJob(id: 'job-7'));

      final results = await future;
      expect(results, isNotEmpty);
      expect(results.first.id, 'job-7');
    });

    test('JobPhase.fromDb round-trips all 6 canonical values', () {
      for (final phase in JobPhase.orderedValues) {
        final roundTripped = JobPhase.fromDb(phase.dbValue);
        expect(
          roundTripped,
          phase,
          reason:
              'fromDb("${phase.dbValue}") should return JobPhase.${phase.name}',
        );
      }
    });

    test(
        'JobPhase.fromDb maps legacy wrong values to correct canonical values',
        () {
      expect(JobPhase.fromDb('scheduled'), JobPhase.rough);
      expect(JobPhase.fromDb('in_progress'), JobPhase.finishing);
      expect(JobPhase.fromDb('punch_list'), JobPhase.walkthrough);
      expect(JobPhase.fromDb('completed'), JobPhase.complete);
    });

    test('JobHealthStatus.fromDb round-trips all 3 canonical values', () {
      for (final status in JobHealthStatus.values) {
        final roundTripped = JobHealthStatus.fromDb(status.dbValue);
        expect(
          roundTripped,
          status,
          reason:
              'fromDb("${status.dbValue}") should return JobHealthStatus.${status.name}',
        );
      }
    });

    test('upsertFromServer saves jobs without creating outbox entries',
        () async {
      final serverJob = LocalJobsCompanion.insert(
        id: 'server-job-1',
        organizationId: orgId,
        clientName: 'Server Client',
        jobType: 'Roofing',
        phase: const Value('rough'),
        healthStatus: const Value('green'),
      );

      await jobsDao.upsertFromServer([serverJob]);

      final job = await jobsDao.getJobById('server-job-1');
      expect(job, isNotNull);
      expect(job!.clientName, 'Server Client');
      expect(job.phase, 'rough');
      expect(job.needsSync, false);
      expect(job.lastSyncedAt, isNotNull);

      // No outbox entries should be created.
      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, isEmpty);
    });

    test('watchJobByLeadId returns only the job linked to that leadId',
        () async {
      await jobsDao.createJob(makeJob(id: 'job-lead-a', leadId: 'lead-x'));
      await jobsDao.createJob(makeJob(id: 'job-lead-b', leadId: 'lead-y'));

      final jobForX = await jobsDao.watchJobByLeadId('lead-x').first;
      expect(jobForX, isNotNull);
      expect(jobForX!.id, 'job-lead-a');

      final jobForY = await jobsDao.watchJobByLeadId('lead-y').first;
      expect(jobForY, isNotNull);
      expect(jobForY!.id, 'job-lead-b');
    });
  });
}
