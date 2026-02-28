import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../app/router/app_router.dart';

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
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kStatuses.length, vsync: this);
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
          itemBuilder: (context, i) => _LeadTile(lead: leads[i]),
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

class _LeadTile extends StatelessWidget {
  const _LeadTile({required this.lead});
  final LocalLead lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updated = DateFormat.MMMd().format(lead.updatedAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor(lead.status, theme),
        foregroundColor: theme.colorScheme.onPrimary,
        child: Text(
          lead.clientName.isNotEmpty ? lead.clientName[0].toUpperCase() : '?',
        ),
      ),
      title: Text(lead.clientName,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text('${lead.jobType}  ·  $updated',
          style: theme.textTheme.bodySmall),
      trailing: _StatusChip(status: lead.status),
      onTap: () => context.push(
        AppRoutes.leadDetail.replaceFirst(':leadId', lead.id),
      ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    final cs = theme.colorScheme;
    return switch (status) {
      'won' => Colors.green.shade600,
      'quoted' => cs.primary,
      'lost' => cs.error,
      'cold' => Colors.blueGrey,
      _ => cs.tertiary,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (status) {
      'new_callback' => 'New',
      'quoted' => 'Quoted',
      'won' => 'Won',
      'cold' => 'Cold',
      'lost' => 'Lost',
      _ => status,
    };
    final color = switch (status) {
      'won' => Colors.green.shade600,
      'quoted' => theme.colorScheme.primary,
      'lost' => theme.colorScheme.error,
      'cold' => Colors.blueGrey,
      _ => theme.colorScheme.tertiary,
    };
    return Chip(
      label: Text(label,
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
