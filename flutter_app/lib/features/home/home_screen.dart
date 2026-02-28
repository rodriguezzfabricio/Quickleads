import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/domain/lead_status_mapper.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/job_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _dismissedWonReminder = false;
  String? _updatingLeadId;

  Future<void> _callLead(BuildContext context, LocalLead lead) async {
    final phone = lead.phoneE164 ?? '';
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this lead.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: phone));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $phone. Open your dialer to call.')),
    );
  }

  Future<void> _markEstimateSent(LocalLead lead) async {
    if (_updatingLeadId != null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estimate Sent?'),
        content: Text(
          'Start the automated follow-up sequence for ${lead.clientName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _updatingLeadId = lead.id);
    try {
      await ref.read(leadsDaoProvider).markEstimateSent(
            lead.id,
            lead.version,
          );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update lead: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingLeadId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final leadsAsync = ref.watch(allLeadsProvider(orgId));
    final jobsAsync = ref.watch(jobsByOrgProvider(orgId));
    final wonLeadsWithoutJobAsync =
        ref.watch(wonLeadsWithoutJobProvider(orgId));

    return Scaffold(
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading dashboard: $error'),
          ),
          data: (leads) => jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error loading dashboard: $error'),
            ),
            data: (jobs) {
              final urgentLeads = leads.where((lead) {
                return LeadStatusMapper.canonicalize(lead.status) ==
                    LeadStatusMapper.callbackDb;
              }).toList();

              final followingUpLeads = leads.where((lead) {
                return LeadStatusMapper.canonicalize(lead.status) ==
                        LeadStatusMapper.estimateDb &&
                    lead.followupState == 'active';
              }).toList();

              final wonLeads = leads.where((lead) {
                return LeadStatusMapper.canonicalize(lead.status) ==
                    LeadStatusMapper.wonDb;
              }).toList();

              final coldCount = leads.where((lead) {
                return LeadStatusMapper.canonicalize(lead.status) ==
                    LeadStatusMapper.coldDb;
              }).length;

              final totalActive = urgentLeads.length + followingUpLeads.length;

              final wonLeadsWithoutJob =
                  wonLeadsWithoutJobAsync.valueOrNull ?? const <LocalLead>[];
              final showWonReminder =
                  wonLeadsWithoutJob.isNotEmpty && !_dismissedWonReminder;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                children: [
                  _DashboardHeader(
                    activeCount: totalActive,
                    wonCount: wonLeads.length,
                    jobsCount: jobs.length,
                    runningFollowupsCount: followingUpLeads.length,
                    onOpenSettings: () => context.push(AppRoutes.settings),
                    onOpenLeads: () => context.go(AppRoutes.leads),
                    onOpenWon: () =>
                        context.go('${AppRoutes.leads}?status=won'),
                    onOpenJobs: () => context.go(AppRoutes.jobs),
                  ),
                  const SizedBox(height: 16),
                  if (urgentLeads.isNotEmpty) ...[
                    const _SectionTitle(
                      title: 'Call Back Now',
                      accentColor: AppTokens.danger,
                    ),
                    const SizedBox(height: 8),
                    ...urgentLeads.map(
                      (lead) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LeadActionCard(
                          lead: lead,
                          variant: _LeadActionVariant.urgent,
                          busy: _updatingLeadId == lead.id,
                          onTap: () => context.push(
                            AppRoutes.leadDetail
                                .replaceFirst(':leadId', lead.id),
                          ),
                          onPrimaryAction: () => _callLead(context, lead),
                          onSecondaryAction: () => _markEstimateSent(lead),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (followingUpLeads.isNotEmpty) ...[
                    const _SectionTitle(
                      title: 'Auto Follow-up',
                      accentColor: AppTokens.primary,
                    ),
                    const SizedBox(height: 8),
                    ...followingUpLeads.map(
                      (lead) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LeadActionCard(
                          lead: lead,
                          variant: _LeadActionVariant.followingUp,
                          onTap: () => context.push(
                            AppRoutes.leadDetail
                                .replaceFirst(':leadId', lead.id),
                          ),
                          onPrimaryAction: () => _callLead(context, lead),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (wonLeads.isNotEmpty) ...[
                    const _SectionTitle(
                      title: 'Won',
                      accentColor: AppTokens.success,
                    ),
                    const SizedBox(height: 8),
                    ...wonLeads.take(2).map(
                          (lead) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _LeadActionCard(
                              lead: lead,
                              variant: _LeadActionVariant.won,
                              onTap: () => context.push(
                                AppRoutes.leadDetail
                                    .replaceFirst(':leadId', lead.id),
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 8),
                  ],
                  if (coldCount > 0)
                    TextButton(
                      onPressed: () =>
                          context.go('${AppRoutes.leads}?status=cold'),
                      child: Text('View $coldCount Cold Leads'),
                    ),
                  if (showWonReminder) ...[
                    const SizedBox(height: 8),
                    _WonReminderBanner(
                      count: wonLeadsWithoutJob.length,
                      onTap: () {
                        if (wonLeadsWithoutJob.length == 1) {
                          context.push(
                            AppRoutes.leadDetail.replaceFirst(
                              ':leadId',
                              wonLeadsWithoutJob.first.id,
                            ),
                          );
                          return;
                        }
                        context.go('${AppRoutes.leads}?status=won');
                      },
                      onDismiss: () {
                        setState(() => _dismissedWonReminder = true);
                      },
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(
                          title: 'Your Jobs',
                          accentColor: AppTokens.warning,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.jobs),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (jobs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTokens.glass,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTokens.glassBorder),
                      ),
                      child: Text(
                        'No jobs yet. Jobs are created from won leads.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...jobs.take(3).map(
                          (job) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: JobTile(job: job),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.activeCount,
    required this.wonCount,
    required this.jobsCount,
    required this.runningFollowupsCount,
    required this.onOpenSettings,
    required this.onOpenLeads,
    required this.onOpenWon,
    required this.onOpenJobs,
  });

  final int activeCount;
  final int wonCount;
  final int jobsCount;
  final int runningFollowupsCount;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLeads;
  final VoidCallback onOpenWon;
  final VoidCallback onOpenJobs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Dashboard', style: theme.textTheme.headlineMedium),
            ),
            IconButton(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
          ],
        ),
        Text(
          '$runningFollowupsCount follow-up${runningFollowupsCount == 1 ? '' : 's'} running',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.groups_outlined,
                label: 'Active',
                value: activeCount,
                color: AppTokens.primary,
                onTap: onOpenLeads,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.emoji_events_outlined,
                label: 'Won',
                value: wonCount,
                color: AppTokens.success,
                onTap: onOpenWon,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.work_outline,
                label: 'Jobs',
                value: jobsCount,
                color: AppTokens.warning,
                onTap: onOpenJobs,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppTokens.glassElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTokens.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(height: 1),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LeadActionVariant { urgent, followingUp, won }

class _LeadActionCard extends StatelessWidget {
  const _LeadActionCard({
    required this.lead,
    required this.variant,
    required this.onTap,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.busy = false,
  });

  final LocalLead lead;
  final _LeadActionVariant variant;
  final VoidCallback onTap;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = switch (variant) {
      _LeadActionVariant.urgent => AppTokens.danger,
      _LeadActionVariant.followingUp => AppTokens.primary,
      _LeadActionVariant.won => AppTokens.success,
    };

    return Material(
      color: AppTokens.glassElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTokens.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 148,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.clientName,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead.jobType,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (variant == _LeadActionVariant.urgent &&
                          onPrimaryAction != null)
                        FilledButton.icon(
                          onPressed: onPrimaryAction,
                          icon: const Icon(Icons.phone_outlined),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: AppTokens.danger,
                          ),
                          label: Text('Call ${lead.phoneE164 ?? ''}'),
                        ),
                      if (variant == _LeadActionVariant.urgent &&
                          onSecondaryAction != null) ...[
                        const SizedBox(height: 6),
                        FilledButton(
                          onPressed: busy ? null : onSecondaryAction,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: const Color(0xFFFFD60A),
                            foregroundColor: Colors.black,
                          ),
                          child: busy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Estimate Sent?'),
                        ),
                      ],
                      if (variant == _LeadActionVariant.followingUp) ...[
                        Text(
                          'Follow-up 1: Day 2 ⏳ Scheduled · '
                          'Follow-up 2: Day 5 ⏳ Scheduled · '
                          'Follow-up 3: Day 10 ⏳ Scheduled',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: onPrimaryAction,
                          icon: const Icon(Icons.phone_outlined),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          label: Text(lead.phoneE164 ?? 'No phone on file'),
                        ),
                      ],
                      if (variant == _LeadActionVariant.won)
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: AppTokens.success,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Won',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTokens.success,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.accentColor,
  });

  final String title;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: accentColor,
              ),
        ),
      ],
    );
  }
}

class _WonReminderBanner extends StatelessWidget {
  const _WonReminderBanner({
    required this.count,
    required this.onTap,
    required this.onDismiss,
  });

  final int count;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color.fromRGBO(255, 214, 10, 0.2),
            border: Border.all(
              color: const Color.fromRGBO(255, 214, 10, 0.4),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'You have $count won lead${count == 1 ? '' : 's'} without a project. Tap to set up.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFFFD60A),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, size: 18),
                color: const Color(0xFFFFD60A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
