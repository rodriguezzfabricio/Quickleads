import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/domain/lead_status_mapper.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../features/auth/providers/auth_provider.dart';

const _kFilters = [
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
  String? _updatingLeadId;
  String? _expandedLeadId;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _normalizeFilter(widget.initialStatus);
  }

  @override
  void didUpdateWidget(covariant LeadsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      _selectedFilter = _normalizeFilter(widget.initialStatus);
      _expandedLeadId = null;
    }
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
      await ref.read(leadActionsServiceProvider).markEstimateSent(lead);
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

  void _handleCardTap(LocalLead lead) {
    if (_expandedLeadId == lead.id) {
      context.push(AppRoutes.leadDetail.replaceFirst(':leadId', lead.id));
      return;
    }
    setState(() => _expandedLeadId = lead.id);
  }

  void _openAddAsClient(LocalLead lead) {
    final query = <String, String>{
      'name': lead.clientName,
      if (lead.phoneE164 != null && lead.phoneE164!.trim().isNotEmpty)
        'phone': lead.phoneE164!,
    };
    final uri = Uri(path: AppRoutes.clientCreate, queryParameters: query);
    context.push(uri.toString());
  }

  void _selectFilter(String filter) {
    final normalizedFilter = _normalizeFilter(filter);
    setState(() {
      _selectedFilter = normalizedFilter;
      _expandedLeadId = null;
    });

    final location = normalizedFilter == 'all'
        ? AppRoutes.leads
        : Uri(
            path: AppRoutes.leads,
            queryParameters: {'status': normalizedFilter},
          ).toString();
    context.go(location);
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
      body: SafeArea(
        child: leadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading leads: $error'),
          ),
          data: (leads) {
            final filtered = _filterLeads(leads, _selectedFilter);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              children: [
                Text('Leads',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 14),
                _FilterStrip(
                  selectedFilter: _selectedFilter,
                  onSelectFilter: _selectFilter,
                ),
                const SizedBox(height: 16),
                _ReviewCallsCard(
                  count: unknownCallsCount,
                  onTap: () => context.push(AppRoutes.dailySweepReview),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  ...filtered.map(
                    (lead) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          _LeadCard(
                            lead: lead,
                            isUpdating: _updatingLeadId == lead.id,
                            onTap: () => _handleCardTap(lead),
                            onEstimateSent:
                                LeadStatusMapper.canonicalize(lead.status) ==
                                        LeadStatusMapper.callbackDb
                                    ? () => _markEstimateSent(lead)
                                    : null,
                          ),
                          if (_expandedLeadId == lead.id)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => context.push(
                                        AppRoutes.leadDetail
                                            .replaceFirst(':leadId', lead.id),
                                      ),
                                      child: const Text('View Profile'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openAddAsClient(lead),
                                      icon: const Icon(Icons.person_add_alt_1),
                                      label: const Text('Add as Client'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.glassElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTokens.glassBorder),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: _kFilters.map((filter) {
          final isSelected = filter.$1 == selectedFilter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelectFilter(filter.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.white.withValues(alpha: 0.18))
                      : null,
                ),
                child: Text(
                  filter.$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReviewCallsCard extends StatelessWidget {
  const _ReviewCallsCard({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.glassElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTokens.glassBorder),
          ),
          child: Row(
            children: [
              Text(
                'Review Calls',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '$count to review',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.isUpdating,
    required this.onTap,
    required this.onEstimateSent,
  });

  final LocalLead lead;
  final bool isUpdating;
  final VoidCallback onTap;
  final VoidCallback? onEstimateSent;

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(lead.status);
    final phone = lead.phoneE164 ?? 'No phone on file';

    return Material(
      color: AppTokens.glassElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTokens.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 31 / 2,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lead.jobType,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.tint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              if (onEstimateSent != null) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: isUpdating ? null : onEstimateSent,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: const Color(0xFFFFD60A),
                    foregroundColor: Colors.black,
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Estimate Sent?',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
              if (_isEstimateLead(lead)) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                const SizedBox(height: 10),
                Text(
                  'Follow-up 1: Day 2 ⏳ Scheduled',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Follow-up 2: Day 5 ⏳ Scheduled',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Follow-up 3: Day 10 ⏳ Scheduled',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Text(
            'No leads found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Use the + button to add a new lead.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.color,
    required this.tint,
  });

  final String label;
  final Color color;
  final Color tint;
}

_StatusStyle _statusStyle(String status) {
  return switch (LeadStatusMapper.canonicalize(status)) {
    LeadStatusMapper.callbackDb => const _StatusStyle(
        label: 'Callback',
        color: AppTokens.danger,
        tint: Color.fromRGBO(255, 69, 58, 0.2),
      ),
    LeadStatusMapper.estimateDb => const _StatusStyle(
        label: 'Estimate',
        color: AppTokens.warning,
        tint: Color.fromRGBO(255, 159, 10, 0.2),
      ),
    LeadStatusMapper.wonDb => const _StatusStyle(
        label: 'Won',
        color: AppTokens.success,
        tint: Color.fromRGBO(74, 158, 126, 0.2),
      ),
    LeadStatusMapper.coldDb => _StatusStyle(
        label: 'Cold',
        color: Colors.white.withValues(alpha: 0.58),
        tint: Colors.white.withValues(alpha: 0.07),
      ),
    _ => _StatusStyle(
        label: LeadStatusMapper.toUiLabel(status),
        color: Colors.white.withValues(alpha: 0.58),
        tint: Colors.white.withValues(alpha: 0.07),
      ),
  };
}

bool _isEstimateLead(LocalLead lead) {
  return LeadStatusMapper.isEstimateLike(lead.status);
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
    LeadStatusMapper.estimateDb => leads.where(_isEstimateLead).toList(),
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
