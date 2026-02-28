import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../app/router/app_router.dart';
import '../../shared/widgets/lead_tile.dart';

// ── Status constants ──────────────────────────────────────────────────────────

const _kStatuses = [
  ('all', 'All'),
  ('new_callback', 'New'),
  ('quoted', 'Quoted'),
  ('won', 'Won'),
  ('cold', 'Cold'),
  ('lost', 'Lost'),
];

// ── LeadsScreen ───────────────────────────────────────────────────────────────

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({
    super.key,
    this.initialStatus,
  });

  final String? initialStatus;

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _kStatuses.length,
      vsync: this,
      initialIndex: _tabIndexForStatus(widget.initialStatus),
    );
  }

  @override
  void didUpdateWidget(covariant LeadsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      final nextIndex = _tabIndexForStatus(widget.initialStatus);
      if (_tabController.index != nextIndex) {
        _tabController.animateTo(nextIndex);
      }
    }
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
        title: const Text('Leads'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _kStatuses.map((s) => Tab(text: s.$2)).toList(),
        ),
      ),
      body: orgId.isEmpty
          ? const _LoadingBody()
          : TabBarView(
              controller: _tabController,
              children: _kStatuses.map((s) {
                final statusKey = s.$1;
                final leadsAsync = statusKey == 'all'
                    ? ref.watch(allLeadsProvider(orgId))
                    : statusKey == 'quoted'
                        ? ref.watch(allLeadsProvider(orgId)).whenData(
                              (leads) => leads
                                  .where(
                                      (lead) => _matchesStatus(lead, statusKey))
                                  .toList(),
                            )
                        : ref.watch(leadsByStatusProvider((
                            orgId: orgId,
                            status: statusKey,
                          )));
                return _LeadsTab(leadsAsync: leadsAsync, statusLabel: s.$2);
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.leadCapture),
        icon: const Icon(Icons.add),
        label: const Text('New Lead'),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _LeadsTab extends StatelessWidget {
  const _LeadsTab({required this.leadsAsync, required this.statusLabel});

  final AsyncValue<List<LocalLead>> leadsAsync;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return leadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading leads: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      data: (leads) {
        if (leads.isEmpty) {
          return _EmptyState(statusLabel: statusLabel);
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: leads.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) => LeadTile(lead: leads[i]),
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
          Icon(Icons.people_outline,
              size: 72, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            isAll ? 'No leads yet' : 'No $statusLabel leads',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isAll ? 'Tap + to capture your first lead.' : '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

int _tabIndexForStatus(String? status) {
  final normalized = switch (status) {
    'new' || 'new_callback' => 'new_callback',
    'quoted' || 'estimate_sent' => 'quoted',
    'won' => 'won',
    'cold' => 'cold',
    'lost' => 'lost',
    _ => 'all',
  };
  final index = _kStatuses.indexWhere((s) => s.$1 == normalized);
  return index == -1 ? 0 : index;
}

bool _matchesStatus(LocalLead lead, String statusKey) {
  if (statusKey == 'quoted') {
    return lead.status == 'quoted' || lead.status == 'estimate_sent';
  }
  return lead.status == statusKey;
}
