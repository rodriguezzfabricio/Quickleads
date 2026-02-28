import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../app_database.dart';

/// Seeds local development data so the simulator has realistic content.
///
/// This only runs in debug builds and only when an org has no leads/jobs yet.
Future<void> seedDebugMockData({
  required AppDatabase db,
  required String organizationId,
}) async {
  if (!kDebugMode || organizationId.isEmpty) {
    return;
  }

  final leadCountExpr = db.localLeads.id.count();
  final leadCountRow = await (db.selectOnly(db.localLeads)
        ..addColumns([leadCountExpr])
        ..where(db.localLeads.organizationId.equals(organizationId)))
      .getSingle();
  final leadCount = leadCountRow.read(leadCountExpr) ?? 0;

  final jobCountExpr = db.localJobs.id.count();
  final jobCountRow = await (db.selectOnly(db.localJobs)
        ..addColumns([jobCountExpr])
        ..where(db.localJobs.organizationId.equals(organizationId)))
      .getSingle();
  final jobCount = jobCountRow.read(jobCountExpr) ?? 0;

  if (leadCount > 0 || jobCount > 0) {
    return;
  }

  final now = DateTime.now();

  await db.transaction(() async {
    await db.batch((batch) {
      batch.insertAll(
        db.localLeads,
        [
          LocalLeadsCompanion.insert(
            id: 'debug-lead-1',
            organizationId: organizationId,
            clientName: 'Mike Johnson',
            phoneE164: const Value('301-555-0123'),
            jobType: 'Deck',
            status: const Value('new_callback'),
            createdAt: Value(now.subtract(const Duration(days: 9))),
            updatedAt: Value(now.subtract(const Duration(days: 9))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-2',
            organizationId: organizationId,
            clientName: 'Sarah Williams',
            phoneE164: const Value('240-555-0456'),
            jobType: 'Kitchen',
            status: const Value('new_callback'),
            createdAt: Value(now.subtract(const Duration(days: 8))),
            updatedAt: Value(now.subtract(const Duration(days: 8))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-3',
            organizationId: organizationId,
            clientName: 'Tom Anderson',
            phoneE164: const Value('301-555-0789'),
            jobType: 'Bathroom',
            status: const Value('estimate_sent'),
            followupState: const Value('active'),
            estimateSentAt: Value(now.subtract(const Duration(days: 6))),
            createdAt: Value(now.subtract(const Duration(days: 11))),
            updatedAt: Value(now.subtract(const Duration(days: 6))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-4',
            organizationId: organizationId,
            clientName: 'Lisa Martinez',
            phoneE164: const Value('240-555-0321'),
            jobType: 'Fence',
            status: const Value('estimate_sent'),
            followupState: const Value('active'),
            estimateSentAt: Value(now.subtract(const Duration(days: 5))),
            createdAt: Value(now.subtract(const Duration(days: 13))),
            updatedAt: Value(now.subtract(const Duration(days: 5))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-5',
            organizationId: organizationId,
            clientName: 'David Chen',
            phoneE164: const Value('301-555-0654'),
            jobType: 'Basement',
            status: const Value('won'),
            estimateSentAt: Value(now.subtract(const Duration(days: 17))),
            createdAt: Value(now.subtract(const Duration(days: 20))),
            updatedAt: Value(now.subtract(const Duration(days: 2))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-6',
            organizationId: organizationId,
            clientName: 'Jennifer Brown',
            phoneE164: const Value('240-555-0987'),
            jobType: 'Roof',
            status: const Value('cold'),
            estimateSentAt: Value(now.subtract(const Duration(days: 22))),
            createdAt: Value(now.subtract(const Duration(days: 26))),
            updatedAt: Value(now.subtract(const Duration(days: 18))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-7',
            organizationId: organizationId,
            clientName: 'Robert Wilson',
            phoneE164: const Value('301-555-1111'),
            jobType: 'Kitchen',
            status: const Value('won'),
            estimateSentAt: Value(now.subtract(const Duration(days: 55))),
            createdAt: Value(now.subtract(const Duration(days: 63))),
            updatedAt: Value(now.subtract(const Duration(days: 4))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-8',
            organizationId: organizationId,
            clientName: 'Patricia Davis',
            phoneE164: const Value('240-555-2222'),
            jobType: 'Deck',
            status: const Value('won'),
            estimateSentAt: Value(now.subtract(const Duration(days: 72))),
            createdAt: Value(now.subtract(const Duration(days: 79))),
            updatedAt: Value(now.subtract(const Duration(days: 5))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-9',
            organizationId: organizationId,
            clientName: 'James Miller',
            phoneE164: const Value('301-555-3333'),
            jobType: 'Bathroom',
            status: const Value('won'),
            estimateSentAt: Value(now.subtract(const Duration(days: 43))),
            createdAt: Value(now.subtract(const Duration(days: 49))),
            updatedAt: Value(now.subtract(const Duration(days: 6))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalLeadsCompanion.insert(
            id: 'debug-lead-10',
            organizationId: organizationId,
            clientName: 'Sarah Connor',
            phoneE164: const Value('555-123-4567'),
            jobType: 'Roof',
            status: const Value('cold'),
            createdAt: Value(now.subtract(const Duration(days: 37))),
            updatedAt: Value(now.subtract(const Duration(days: 7))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );

      batch.insertAll(
        db.localJobs,
        [
          LocalJobsCompanion.insert(
            id: 'debug-job-1',
            organizationId: organizationId,
            leadId: const Value('debug-lead-7'),
            clientName: 'Robert Wilson',
            jobType: 'Kitchen',
            phase: const Value('rough'),
            healthStatus: const Value('green'),
            estimatedCompletionDate: Value(
              now.add(const Duration(days: 20)),
            ),
            createdAt: Value(now.subtract(const Duration(days: 30))),
            updatedAt: Value(now.subtract(const Duration(days: 3))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalJobsCompanion.insert(
            id: 'debug-job-2',
            organizationId: organizationId,
            leadId: const Value('debug-lead-8'),
            clientName: 'Patricia Davis',
            jobType: 'Deck',
            phase: const Value('finishing'),
            healthStatus: const Value('yellow'),
            estimatedCompletionDate: Value(
              now.add(const Duration(days: 8)),
            ),
            createdAt: Value(now.subtract(const Duration(days: 42))),
            updatedAt: Value(now.subtract(const Duration(days: 4))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalJobsCompanion.insert(
            id: 'debug-job-3',
            organizationId: organizationId,
            leadId: const Value('debug-lead-9'),
            clientName: 'James Miller',
            jobType: 'Bathroom',
            phase: const Value('demo'),
            healthStatus: const Value('red'),
            estimatedCompletionDate: Value(
              now.add(const Duration(days: 3)),
            ),
            createdAt: Value(now.subtract(const Duration(days: 18))),
            updatedAt: Value(now.subtract(const Duration(days: 5))),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );

      batch.insertAll(
        db.localCallLogs,
        [
          LocalCallLogsCompanion.insert(
            id: 'debug-call-1',
            organizationId: organizationId,
            phoneE164: '240-555-6671',
            platform: 'ios',
            source: 'native_observer',
            startedAt: now.subtract(const Duration(hours: 6)),
            durationSec: const Value(252),
            disposition: const Value('unknown'),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalCallLogsCompanion.insert(
            id: 'debug-call-2',
            organizationId: organizationId,
            phoneE164: '301-555-9914',
            platform: 'ios',
            source: 'native_observer',
            startedAt: now.subtract(const Duration(hours: 9)),
            durationSec: const Value(86),
            disposition: const Value('unknown'),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
          LocalCallLogsCompanion.insert(
            id: 'debug-call-3',
            organizationId: organizationId,
            phoneE164: '443-555-1045',
            platform: 'ios',
            source: 'native_observer',
            startedAt: now.subtract(const Duration(hours: 12)),
            durationSec: const Value(401),
            disposition: const Value('unknown'),
            needsSync: const Value(false),
            lastSyncedAt: Value(now),
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  });
}
