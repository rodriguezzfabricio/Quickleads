import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/lead_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final wonLeadsWithoutJobAsync =
        ref.watch(wonLeadsWithoutJobProvider(orgId));
    final leadsAsync = ref.watch(allLeadsProvider(orgId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Error loading dashboard: $error')),
          data: (leads) {
            final pipelineCounts = _buildPipelineCounts(leads);
            final recentLeads = leads.take(5).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                wonLeadsWithoutJobAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Could not load reminders: $error',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  data: (wonLeadsWithoutJob) {
                    if (wonLeadsWithoutJob.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Action Required'),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 170,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: wonLeadsWithoutJob.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final lead = wonLeadsWithoutJob[index];
                                return _ActionCard(
                                  lead: lead,
                                  onStartJob: () => context.push(
                                    AppRoutes.leadDetail
                                        .replaceFirst(':leadId', lead.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const _SectionTitle(title: "Today's Pipeline"),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PipelineChip(
                      label: 'New',
                      count: pipelineCounts.newCount,
                      onTap: () =>
                          context.go('${AppRoutes.leads}?status=new_callback'),
                    ),
                    _PipelineChip(
                      label: 'Quoted',
                      count: pipelineCounts.quotedCount,
                      onTap: () =>
                          context.go('${AppRoutes.leads}?status=quoted'),
                    ),
                    _PipelineChip(
                      label: 'Won',
                      count: pipelineCounts.wonCount,
                      onTap: () => context.go('${AppRoutes.leads}?status=won'),
                    ),
                    _PipelineChip(
                      label: 'Cold',
                      count: pipelineCounts.coldCount,
                      onTap: () => context.go('${AppRoutes.leads}?status=cold'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: _SectionTitle(title: 'Recent Leads'),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.leads),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (recentLeads.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No leads yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentLeads.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) =>
                        LeadTile(lead: recentLeads[index]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.lead,
    required this.onStartJob,
  });

  final LocalLead lead;
  final VoidCallback onStartJob;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lead.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                lead.jobType,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onStartJob,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                ),
                child: const Text('Start Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipelineChip extends StatelessWidget {
  const _PipelineChip({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      onPressed: onTap,
      avatar: CircleAvatar(
        radius: 12,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.22),
        child: Text(
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      label: Text(label),
      labelStyle: theme.textTheme.labelLarge,
      backgroundColor: theme.cardTheme.color,
    );
  }
}

class _PipelineCounts {
  const _PipelineCounts({
    required this.newCount,
    required this.quotedCount,
    required this.wonCount,
    required this.coldCount,
  });

  final int newCount;
  final int quotedCount;
  final int wonCount;
  final int coldCount;
}

_PipelineCounts _buildPipelineCounts(List<LocalLead> leads) {
  var newCount = 0;
  var quotedCount = 0;
  var wonCount = 0;
  var coldCount = 0;

  for (final lead in leads) {
    switch (lead.status) {
      case 'new_callback':
        newCount++;
      case 'quoted':
      case 'estimate_sent':
        quotedCount++;
      case 'won':
        wonCount++;
      case 'cold':
      case 'lost':
        coldCount++;
    }
  }

  return _PipelineCounts(
    newCount: newCount,
    quotedCount: quotedCount,
    wonCount: wonCount,
    coldCount: coldCount,
  );
}
