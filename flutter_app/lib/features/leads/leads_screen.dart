import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/lead_status_mapper.dart';
import '../../core/services/lead_actions_service.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/lead_card.dart';

const _filters = [
  ('all', 'All'),
  ('new_callback', 'Callback'),
  ('estimate_sent', 'Estimate'),
  ('won', 'Won'),
  ('cold', 'Cold'),
];

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({
    super.key,
    this.initialStatus,
  });

  final String? initialStatus;

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  late String _selectedFilter;
  String? _expandedLeadId;
  String? _updatingLeadId;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _normalizeFilter(widget.initialStatus);
  }

  @override
  void didUpdateWidget(covariant LeadsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != oldWidget.initialStatus) {
      _selectedFilter = _normalizeFilter(widget.initialStatus);
      _expandedLeadId = null;
    }
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

  void _selectFilter(String filter) {
    final normalized = _normalizeFilter(filter);
    setState(() {
      _selectedFilter = normalized;
      _expandedLeadId = null;
    });

    final location = normalized == 'all'
        ? AppRoutes.leads
        : Uri(path: AppRoutes.leads, queryParameters: {'status': normalized})
            .toString();
    context.go(location);
  }

  void _handleLeadTap(LocalLead lead) {
    if (_expandedLeadId == lead.id) {
      context.push(AppRoutes.leadDetail.replaceFirst(':leadId', lead.id));
      return;
    }
    setState(() => _expandedLeadId = lead.id);
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final leadsAsync = ref.watch(allLeadsProvider(orgId));
    final unknownCallsCount =
        ref.watch(unknownCallsProvider(orgId)).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading leads: $error'),
          ),
          data: (leads) {
            final filtered = _filterLeads(leads, _selectedFilter);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              children: [
                _stagger(
                  0,
                  Text('Leads', style: AppTextStyles.h1),
                ),
                const SizedBox(height: 12),
                _stagger(
                  1,
                  _FilterStrip(
                    selectedFilter: _selectedFilter,
                    onSelectFilter: _selectFilter,
                  ),
                ),
                const SizedBox(height: 12),
                _stagger(
                  2,
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.dailySweepReview),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_callback_outlined,
                              size: 18, color: AppColors.systemBlue),
                          const SizedBox(width: 10),
                          Text(
                            'Review Calls',
                            style: AppTextStyles.h4.copyWith(
                              fontSize: 15,
                              color: AppColors.foreground,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.systemBlue,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$unknownCallsCount',
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      children: [
                        Text(
                          'No leads found',
                          style: AppTextStyles.h3.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + to add a new lead',
                          style: AppTextStyles.label,
                        ),
                      ],
                    ),
                  )
                else
                  for (var i = 0; i < filtered.length; i++) ...[
                    _stagger(
                      i + 3,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LeadCard(
                          lead: filtered[i],
                          expanded: _expandedLeadId == filtered[i].id,
                          onTap: () => _handleLeadTap(filtered[i]),
                          onEstimateSent: LeadStatusMapper.canonicalize(
                                      filtered[i].status) ==
                                  LeadStatusMapper.callbackDb
                              ? () => _markEstimateSent(filtered[i])
                              : null,
                          onViewProfile: () => context.push(
                            AppRoutes.leadDetail
                                .replaceFirst(':leadId', filtered[i].id),
                          ),
                          onAddAsClient: () {
                            final query = <String, String>{
                              'leadId': filtered[i].id,
                              'name': filtered[i].clientName,
                              if (filtered[i].phoneE164 != null &&
                                  filtered[i].phoneE164!.trim().isNotEmpty)
                                'phone': filtered[i].phoneE164!,
                            };
                            final uri = Uri(
                                path: AppRoutes.clientCreate,
                                queryParameters: query);
                            context.push(uri.toString());
                          },
                        ),
                      ),
                    ),
                  ],
              ],
            );
          },
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
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.glassElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            for (final filter in _filters)
              GestureDetector(
                onTap: () => onSelectFilter(filter.$1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selectedFilter == filter.$1
                        ? AppColors.glassProminent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filter.$2,
                    style: AppTextStyles.label.copyWith(
                      textBaseline: TextBaseline.alphabetic,
                      fontSize: 13,
                      letterSpacing: 0,
                      color: selectedFilter == filter.$1
                          ? AppColors.foreground
                          : AppColors.mutedFg,
                      fontWeight: selectedFilter == filter.$1
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _normalizeFilter(String? status) {
  final canonical = LeadStatusMapper.canonicalize(status ?? 'all');
  return switch (canonical) {
    LeadStatusMapper.callbackDb => LeadStatusMapper.callbackDb,
    LeadStatusMapper.estimateDb => LeadStatusMapper.estimateDb,
    LeadStatusMapper.wonDb => LeadStatusMapper.wonDb,
    LeadStatusMapper.coldDb => LeadStatusMapper.coldDb,
    _ => 'all',
  };
}

List<LocalLead> _filterLeads(List<LocalLead> leads, String filter) {
  return switch (filter) {
    'all' => leads,
    LeadStatusMapper.callbackDb => leads
        .where(
          (lead) =>
              LeadStatusMapper.canonicalize(lead.status) ==
              LeadStatusMapper.callbackDb,
        )
        .toList(),
    LeadStatusMapper.estimateDb => leads
        .where(
          (lead) =>
              LeadStatusMapper.canonicalize(lead.status) ==
              LeadStatusMapper.estimateDb,
        )
        .toList(),
    LeadStatusMapper.wonDb => leads
        .where(
          (lead) =>
              LeadStatusMapper.canonicalize(lead.status) ==
              LeadStatusMapper.wonDb,
        )
        .toList(),
    LeadStatusMapper.coldDb => leads
        .where(
          (lead) =>
              LeadStatusMapper.canonicalize(lead.status) ==
              LeadStatusMapper.coldDb,
        )
        .toList(),
    _ => leads,
  };
}
