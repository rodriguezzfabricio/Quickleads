import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/lead_status_mapper.dart';
import '../../core/services/lead_actions_service.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/job_card.dart';
import '../../shared/widgets/lead_action_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _dismissedWonReminder = false;
  String? _updatingLeadId;

  Future<void> _callLead(LocalLead lead) async {
    final phone = lead.phoneE164;
    if (phone == null || phone.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this lead.')),
      );
      return;
    }

    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
  }

  Future<void> _markEstimateSent(LocalLead lead) async {
    if (_updatingLeadId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start automatic follow-ups?',
                style: AppTextStyles.h2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Start automatic follow-ups for ${lead.clientName}?',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.systemYellow,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('No',
                          style: AppTextStyles.h4.copyWith(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _updatingLeadId = lead.id);
    try {
      final result =
          await ref.read(leadActionsServiceProvider).markEstimateSent(lead);
      if (!mounted) return;
      if (result.persistence == EstimateSentPersistence.queuedLocally) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved locally. Syncing to cloud in background.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
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
      backgroundColor: AppColors.background,
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

              final totalActive = urgentLeads.length + followingUpLeads.length;
              final wonLeadsWithoutJob =
                  wonLeadsWithoutJobAsync.valueOrNull ?? const <LocalLead>[];
              final showWonReminder =
                  wonLeadsWithoutJob.isNotEmpty && !_dismissedWonReminder;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
                children: [
                  _stagger(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Dashboard', style: AppTextStyles.h1),
                            ),
                            IconButton(
                              onPressed: () => context.push(AppRoutes.settings),
                              icon: const Icon(
                                Icons.settings_outlined,
                                size: 22,
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${followingUpLeads.length} follow-up${followingUpLeads.length == 1 ? '' : 's'} running',
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _stagger(
                    1,
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.people_alt_outlined,
                            iconColor: AppColors.systemBlue,
                            label: 'ACTIVE',
                            value: totalActive,
                            onTap: () => context.go(AppRoutes.leads),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.emoji_events_outlined,
                            iconColor: AppColors.systemGreen,
                            label: 'WON',
                            value: wonLeads.length,
                            onTap: () =>
                                context.go('${AppRoutes.leads}?status=won'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.work_outline,
                            iconColor: AppColors.systemOrange,
                            label: 'JOBS',
                            value: jobs.length,
                            onTap: () => context.go(AppRoutes.jobs),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (urgentLeads.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _stagger(
                      2,
                      const _SectionHeader(
                        label: 'CALL BACK NOW',
                        color: AppColors.systemRed,
                        icon: Icons.circle,
                        pulseDot: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < urgentLeads.length; i++) ...[
                      _stagger(
                        3 + i,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LeadActionCard(
                            lead: urgentLeads[i],
                            variant: LeadActionVariant.urgent,
                            elapsedText: _timeAgo(urgentLeads[i].createdAt),
                            busy: _updatingLeadId == urgentLeads[i].id,
                            onTap: () => context.push(
                              AppRoutes.leadDetail
                                  .replaceFirst(':leadId', urgentLeads[i].id),
                            ),
                            onCall: () => _callLead(urgentLeads[i]),
                            onEstimateSent: () =>
                                _markEstimateSent(urgentLeads[i]),
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (followingUpLeads.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _stagger(
                      5,
                      const _SectionHeader(
                        label: 'AUTO FOLLOW-UP',
                        color: AppColors.systemBlue,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < followingUpLeads.length; i++) ...[
                      _stagger(
                        6 + i,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LeadActionCard(
                            lead: followingUpLeads[i],
                            variant: LeadActionVariant.followingUp,
                            onTap: () => context.push(
                              AppRoutes.leadDetail.replaceFirst(
                                ':leadId',
                                followingUpLeads[i].id,
                              ),
                            ),
                            onCall: () => _callLead(followingUpLeads[i]),
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (wonLeads.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _stagger(
                      8,
                      const _SectionHeader(
                        label: 'WON',
                        color: AppColors.systemGreen,
                        icon: Icons.check_circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < wonLeads.take(2).length; i++) ...[
                      _stagger(
                        9 + i,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LeadActionCard(
                            lead: wonLeads[i],
                            variant: LeadActionVariant.won,
                            onTap: () => context.push(
                              AppRoutes.leadDetail
                                  .replaceFirst(':leadId', wonLeads[i].id),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (showWonReminder) ...[
                    const SizedBox(height: 8),
                    _stagger(
                      12,
                      GestureDetector(
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
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                AppColors.systemYellow.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  AppColors.systemYellow.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'You have ${wonLeadsWithoutJob.length} won lead${wonLeadsWithoutJob.length == 1 ? '' : 's'} without a project. ',
                                        style: AppTextStyles.secondary.copyWith(
                                          fontSize: 15,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Tap to set up.',
                                        style: AppTextStyles.secondary.copyWith(
                                          fontSize: 15,
                                          color: AppColors.systemBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => _dismissedWonReminder = true);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.systemYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _stagger(
                    13,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'YOUR JOBS',
                            style: AppTextStyles.sectionLabel,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.jobs),
                          child: Text(
                            'See All',
                            style: AppTextStyles.secondary.copyWith(
                              color: AppColors.systemBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (jobs.isEmpty)
                    GlassCard(
                      child: Text(
                        'No jobs yet. Jobs are created from won leads.',
                        style: AppTextStyles.secondary,
                      ),
                    )
                  else
                    for (var i = 0; i < jobs.take(3).length; i++) ...[
                      _stagger(
                        14 + i,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: JobCard(
                            job: jobs[i],
                            onTap: () => context.push(
                              AppRoutes.jobDetail
                                  .replaceFirst(':jobId', jobs[i].id),
                            ),
                          ),
                        ),
                      ),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _stagger(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 40)),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final delayed = ((value - (index * 0.03)).clamp(0, 1)).toDouble();
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, (1 - delayed) * 8),
            child: child,
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MetricTile extends StatefulWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int value;
  final VoidCallback onTap;

  @override
  State<_MetricTile> createState() => _MetricTileState();
}

class _MetricTileState extends State<_MetricTile> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) => setState(() => _scale = 1),
        onTap: widget.onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, size: 24, color: widget.iconColor),
              const SizedBox(height: 8),
              Text(
                '${widget.value}',
                style: AppTextStyles.h2.copyWith(fontSize: 28, height: 1),
              ),
              const SizedBox(height: 4),
              Text(widget.label, style: AppTextStyles.sectionLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatefulWidget {
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
    this.pulseDot = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool pulseDot;

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.pulseDot)
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.3).animate(_controller),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          )
        else
          Icon(widget.icon, size: 14, color: widget.color),
        const SizedBox(width: 8),
        Text(widget.label, style: AppTextStyles.sectionLabel),
      ],
    );
  }
}
