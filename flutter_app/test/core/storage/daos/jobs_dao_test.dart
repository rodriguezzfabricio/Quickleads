import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

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
      required String leadId,
      DateTime? estimatedCompletionDate,
    }) {
      return LocalJobsCompanion.insert(
        id: id,
        organizationId: orgId,
        leadId: Value(leadId),
        clientName: 'Client $id',
        jobType: 'Kitchen Remodel',
        estimatedCompletionDate: estimatedCompletionDate != null
            ? Value(estimatedCompletionDate)
            : const Value.absent(),
      );
    }

    test('createJob inserts a job with lead link and estimated date', () async {
      final estimatedDate = DateTime(2026, 3, 10);
      await jobsDao.createJob(
        makeJob(
          id: 'job-1',
          leadId: 'lead-1',
          estimatedCompletionDate: estimatedDate,
        ),
      );

      final job = await jobsDao.getJobById('job-1');
      expect(job, isNotNull);
      expect(job!.leadId, 'lead-1');
      expect(job.estimatedCompletionDate, estimatedDate);
      expect(job.needsSync, true);
    });

    test('createJob queues one sync action with job payload', () async {
      final estimatedDate = DateTime(2026, 4, 5);
      await jobsDao.createJob(
        makeJob(
          id: 'job-2',
          leadId: 'lead-2',
          estimatedCompletionDate: estimatedDate,
        ),
      );

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(1));
      final action = actions.first;
      expect(action.entityType, 'job');
      expect(action.entityId, 'job-2');
      expect(action.mutationType, 'insert');

      final payload = jsonDecode(action.payload) as Map<String, dynamic>;
      expect(payload['id'], 'job-2');
      expect(payload['lead_id'], 'lead-2');
      expect(payload['estimated_completion_date'],
          estimatedDate.toIso8601String());
    });

    test('watchJobByLeadId returns active linked job and ignores deleted rows',
        () async {
      await jobsDao.createJob(
        makeJob(
          id: 'job-active',
          leadId: 'lead-3',
          estimatedCompletionDate: DateTime(2026, 2, 20),
        ),
      );

      await db.into(db.localJobs).insert(
            LocalJobsCompanion.insert(
              id: 'job-deleted',
              organizationId: orgId,
              leadId: const Value('lead-3'),
              clientName: 'Deleted Client',
              jobType: 'Bathroom Remodel',
              deletedAt: Value(DateTime(2026, 2, 21)),
            ),
          );

      final job = await jobsDao.watchJobByLeadId('lead-3').first;
      expect(job, isNotNull);
      expect(job!.id, 'job-active');
    });
  });
}
