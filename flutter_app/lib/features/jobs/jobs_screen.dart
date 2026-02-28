import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/job_tile.dart';

// ── Health‑status tabs (maps to user‑facing "status") ─────────────────────────

const _kHealthStatuses = [
  ('all', 'All'),
  ('green', 'Active'),
  ('yellow', 'On Hold'),
  ('red', 'Completed'),
];

// ── JobsScreen ────────────────────────────────────────────────────────────────

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kHealthStatuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _kHealthStatuses.map((s) => Tab(text: s.$2)).toList(),
        ),
      ),
      body: orgId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _kHealthStatuses.map((s) {
                final statusKey = s.$1;
                final jobsAsync = statusKey == 'all'
                    ? ref.watch(jobsByOrgProvider(orgId))
                    : ref.watch(jobsByHealthStatusProvider((
                        orgId: orgId,
                        healthStatus: statusKey,
                      )));
                return _JobsTab(jobsAsync: jobsAsync, statusLabel: s.$2);
              }).toList(),
            ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _JobsTab extends StatelessWidget {
  const _JobsTab({required this.jobsAsync, required this.statusLabel});

  final AsyncValue<List<LocalJob>> jobsAsync;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading jobs: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return _EmptyState(statusLabel: statusLabel);
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) => JobTile(job: jobs[i]),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.statusLabel});
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final isAll = statusLabel == 'All';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_outline,
              size: 72, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            isAll ? 'No jobs yet' : 'No $statusLabel jobs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isAll ? 'Jobs are created from won leads.' : '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
