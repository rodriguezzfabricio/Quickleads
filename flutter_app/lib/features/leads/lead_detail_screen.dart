import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/lead_status_mapper.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';

const _kStatusOptions = [
  (LeadStatusMapper.callbackDb, 'New / Callback'),
  (LeadStatusMapper.wonDb, 'Won'),
  (LeadStatusMapper.coldDb, 'Cold'),
];

const _uuid = Uuid();

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, this.leadId});

  final String? leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (leadId == null || leadId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Detail')),
        body: const Center(child: Text('No lead ID provided.')),
      );
    }

    final leadAsync = ref.watch(_leadByIdProvider(leadId!));

    return leadAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Lead')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Lead')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (lead) {
        if (lead == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lead')),
            body: const Center(child: Text('Lead not found or was deleted.')),
          );
        }
        return _LeadDetailBody(lead: lead);
      },
    );
  }
}

final _leadByIdProvider = StreamProvider.family<LocalLead?, String>((ref, id) {
  return ref.watch(leadsDaoProvider).watchLeadById(id);
});

class _LeadDetailBody extends ConsumerStatefulWidget {
  const _LeadDetailBody({required this.lead});
  final LocalLead lead;

  @override
  ConsumerState<_LeadDetailBody> createState() => _LeadDetailBodyState();
}

class _LeadDetailBodyState extends ConsumerState<_LeadDetailBody> {
  late String _pendingStatus;
  bool _updatingStatus = false;
  bool _busyAction = false;

  @override
  void initState() {
    super.initState();
    _pendingStatus = LeadStatusMapper.canonicalize(widget.lead.status);
  }

  @override
  void didUpdateWidget(_LeadDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lead.status != oldWidget.lead.status && !_updatingStatus) {
      _pendingStatus = LeadStatusMapper.canonicalize(widget.lead.status);
    }
  }

  Future<void> _copyPhoneForAction({required String actionLabel}) async {
    final phone = widget.lead.phoneE164;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this lead.')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: phone));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$actionLabel copied $phone to clipboard.')),
    );
  }

  Future<void> _changeStatus(String newStatus) async {
    final normalizedNew = LeadStatusMapper.canonicalize(newStatus);
    final currentStatus = LeadStatusMapper.canonicalize(widget.lead.status);
    if (normalizedNew == currentStatus) return;

    final shouldProceed = await _confirmStatusChange(normalizedNew);
    if (!shouldProceed || !mounted) {
      return;
    }

    setState(() {
      _pendingStatus = normalizedNew;
      _updatingStatus = true;
    });

    try {
      await ref.read(leadsDaoProvider).updateLeadStatus(
            widget.lead.id,
            normalizedNew,
            widget.lead.version,
          );

      if (normalizedNew == LeadStatusMapper.wonDb ||
          normalizedNew == LeadStatusMapper.coldDb) {
        await ref.read(leadsDaoProvider).updateFollowupState(
              widget.lead.id,
              'stopped',
              widget.lead.version + 1,
            );
      }

      if (normalizedNew == LeadStatusMapper.wonDb && mounted) {
        await _showWonCelebration();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update lead status: $error')),
      );
      setState(() {
        _pendingStatus = currentStatus;
      });
    } finally {
      if (mounted) {
        setState(() => _updatingStatus = false);
      }
    }
  }

  Future<bool> _confirmStatusChange(String normalizedStatus) async {
    if (!LeadStatusMapper.isTerminal(normalizedStatus)) {
      return true;
    }

    final (title, message, confirmLabel) = switch (normalizedStatus) {
      LeadStatusMapper.wonDb => (
          'Mark as Won?',
          'Mark as Won? This will stop follow-ups and unlock project setup.',
          'Mark Won',
        ),
      LeadStatusMapper.coldDb => (
          'Mark as Cold?',
          'Mark as Cold? This will stop follow-ups.',
          'Mark Cold',
        ),
      _ => ('', '', ''),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _markEstimateSent() async {
    if (_busyAction) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estimate Sent?'),
        content: Text(
          'Start the automated follow-up sequence for ${widget.lead.clientName}?',
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

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busyAction = true);
    try {
      await ref.read(leadsDaoProvider).markEstimateSent(
            widget.lead.id,
            widget.lead.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not mark estimate sent: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busyAction = false);
      }
    }
  }

  Future<void> _openConvertToJobSheet(LocalLead lead) async {
    final createdJob = await showModalBottomSheet<_CreatedJobResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConvertLeadToJobSheet(lead: lead),
    );

    if (!mounted || createdJob == null) {
      return;
    }

    context.push(
      AppRoutes.jobDetail.replaceFirst(':jobId', createdJob.jobId),
    );
  }

  Future<void> _showWonCelebration() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 34),
                ),
                const SizedBox(height: 14),
                Text(
                  'Job Won!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.lead.clientName} — ${widget.lead.jobType}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openProjectCreation(widget.lead);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Set Up Project →'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(AppRoutes.leads);
                  },
                  child: const Text("I'll do this later"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openProjectCreation(LocalLead lead) {
    final query = <String, String>{
      'leadId': lead.id,
      'name': lead.clientName,
      'jobType': lead.jobType,
      if (lead.phoneE164 != null && lead.phoneE164!.trim().isNotEmpty)
        'phone': lead.phoneE164!,
    };
    final uri = Uri(path: AppRoutes.projectCreate, queryParameters: query);
    context.push(uri.toString());
  }

  Future<void> _updateFollowupState(
    String nextState,
    LocalFollowupSequence? sequence,
  ) async {
    if (_busyAction) {
      return;
    }

    final prompt = switch (nextState) {
      'paused' => (
          'Pause follow-ups?',
          'You can resume follow-ups anytime.',
          'Pause',
        ),
      'stopped' => (
          'Stop follow-ups?',
          'This will stop all scheduled follow-ups for this lead.',
          'Stop',
        ),
      _ => (
          'Update follow-ups?',
          'Continue?',
          'Confirm',
        ),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prompt.$1),
        content: Text(prompt.$2),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(prompt.$3),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busyAction = true);
    try {
      await ref.read(leadsDaoProvider).updateFollowupState(
            widget.lead.id,
            nextState,
            widget.lead.version,
          );

      if (sequence != null) {
        await ref.read(followupsDaoProvider).updateSequenceState(
              sequence.id,
              nextState,
            );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update follow-ups: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busyAction = false);
      }
    }
  }

  Future<void> _deleteLead() async {
    if (_busyAction) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.lead.clientName}?'),
        content: const Text('This will remove the lead from your local list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busyAction = true);
    try {
      await ref.read(leadsDaoProvider).softDeleteLead(
            widget.lead.id,
            widget.lead.version,
          );
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.leads);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete lead: $error')),
      );
      setState(() => _busyAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lead = widget.lead;
    final dateFormat = DateFormat.yMMMMd();
    final canonicalStatus = LeadStatusMapper.canonicalize(lead.status);
    final jobForLeadAsync = canonicalStatus == LeadStatusMapper.wonDb
        ? ref.watch(jobForLeadProvider(lead.id))
        : null;
    final followupSequenceAsync =
        ref.watch(followupSequenceByLeadProvider(lead.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(lead.clientName, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardSectionTitle(
                      icon: Icons.work_history_outlined,
                      label: 'Previous Projects',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No project history',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A84FF), Color(0xFF34C759)],
                ),
              ),
              child: FilledButton.icon(
                onPressed: () => _openProjectCreation(lead),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_outlined,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Lead Status',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_updatingStatus)
                      const Center(
                        child: SizedBox(
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (canonicalStatus == LeadStatusMapper.estimateDb)
                      Text(
                        'Estimate Sent',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFFF9F0A),
                        ),
                      )
                    else
                      SegmentedButton<String>(
                        segments: _kStatusOptions
                            .map((s) => ButtonSegment<String>(
                                  value: s.$1,
                                  label: Text(s.$2),
                                ))
                            .toList(),
                        selected: {_pendingStatus},
                        onSelectionChanged: (sel) => _changeStatus(sel.first),
                        style: SegmentedButton.styleFrom(
                          textStyle: theme.textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (canonicalStatus == LeadStatusMapper.wonDb) ...[
              const SizedBox(height: 16),
              _WonLeadConversionCard(
                lead: lead,
                jobForLeadAsync: jobForLeadAsync!,
                onStartJob: () => _openConvertToJobSheet(lead),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardSectionTitle(
                        icon: Icons.person_outline, label: 'Contact'),
                    const SizedBox(height: 12),
                    _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        value: lead.clientName),
                    if (lead.phoneE164 != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: lead.phoneE164!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardSectionTitle(
                        icon: Icons.construction_outlined,
                        label: 'Job Details'),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.build_outlined,
                      label: 'Job Type',
                      value: lead.jobType,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.flag_outlined,
                      label: 'Status',
                      value: LeadStatusMapper.toUiLabel(canonicalStatus),
                    ),
                    if (lead.estimateSentAt != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Estimate Sent',
                        value:
                            dateFormat.format(lead.estimateSentAt!.toLocal()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (lead.followupState == 'active' ||
                lead.followupState == 'paused') ...[
              const SizedBox(height: 16),
              followupSequenceAsync.when(
                loading: () => const SizedBox(
                  height: 96,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Could not load follow-up sequence: $error'),
                  ),
                ),
                data: (sequence) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              lead.followupState == 'paused'
                                  ? 'Follow-up Paused'
                                  : 'Follow-up Active',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _busyAction
                                  ? null
                                  : () =>
                                      _updateFollowupState('paused', sequence),
                              icon: const Icon(Icons.pause),
                              label: const Text('Pause'),
                            ),
                            TextButton.icon(
                              onPressed: _busyAction
                                  ? null
                                  : () =>
                                      _updateFollowupState('stopped', sequence),
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: const Text('Stop'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Day 2: ⏳ Scheduled',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          'Day 5: ⏳ Scheduled',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          'Day 10: ⏳ Scheduled',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _copyPhoneForAction(actionLabel: 'Call'),
              icon: const Icon(Icons.phone),
              label: const Text('Call Now'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _copyPhoneForAction(actionLabel: 'Text'),
              icon: const Icon(Icons.message_outlined),
              label: const Text('Send Text'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            if (canonicalStatus == LeadStatusMapper.callbackDb) ...[
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _busyAction ? null : _markEstimateSent,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFFFFD60A),
                  foregroundColor: Colors.black,
                ),
                child: _busyAction
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Estimate Sent?'),
              ),
            ],
            if (canonicalStatus == LeadStatusMapper.estimateDb) ...[
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _busyAction
                    ? null
                    : () => _changeStatus(LeadStatusMapper.wonDb),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                ),
                child: const Text('Mark as Won'),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busyAction ? null : _deleteLead,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Lead'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Created ${dateFormat.format(lead.createdAt.toLocal())}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ),
                  if (lead.needsSync)
                    Row(
                      children: [
                        Icon(Icons.sync_outlined,
                            size: 14, color: theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          'Pending sync',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _WonLeadConversionCard extends StatelessWidget {
  const _WonLeadConversionCard({
    required this.lead,
    required this.jobForLeadAsync,
    required this.onStartJob,
  });

  final LocalLead lead;
  final AsyncValue<LocalJob?> jobForLeadAsync;
  final VoidCallback onStartJob;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: jobForLeadAsync.when(
          loading: () => const SizedBox(
            height: 88,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not load linked job.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '$error',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          data: (job) {
            if (job != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardSectionTitle(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Job Created',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This won lead is already linked to a job.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(
                      AppRoutes.jobDetail.replaceFirst(':jobId', job.id),
                    ),
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: const Text('View Job →'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardSectionTitle(
                  icon: Icons.bolt_outlined,
                  label: 'Action Required',
                ),
                const SizedBox(height: 8),
                Text(
                  'This lead is won but does not have a job yet.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onStartJob,
                  icon: const Icon(Icons.work_outline),
                  label: const Text('Start Job from This Lead'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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

class _CreatedJobResult {
  const _CreatedJobResult({required this.jobId});
  final String jobId;
}

class _ConvertLeadToJobSheet extends ConsumerStatefulWidget {
  const _ConvertLeadToJobSheet({required this.lead});
  final LocalLead lead;

  @override
  ConsumerState<_ConvertLeadToJobSheet> createState() =>
      _ConvertLeadToJobSheetState();
}

class _ConvertLeadToJobSheetState
    extends ConsumerState<_ConvertLeadToJobSheet> {
  late final TextEditingController _jobTitleController;
  DateTime? _estimatedStartDate;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController(text: widget.lead.jobType);
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    super.dispose();
  }

  bool get _canConfirm =>
      _jobTitleController.text.trim().isNotEmpty &&
      _estimatedStartDate != null &&
      !_creating;

  Future<void> _pickEstimatedStartDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimatedStartDate ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _estimatedStartDate = picked);
    }
  }

  Future<void> _confirmCreateJob() async {
    if (!_canConfirm) return;

    setState(() => _creating = true);
    try {
      final selectedDate = _estimatedStartDate!;
      final normalizedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final jobId = _uuid.v4();
      final companion = LocalJobsCompanion.insert(
        id: jobId,
        organizationId: widget.lead.organizationId,
        leadId: Value(widget.lead.id),
        clientName: widget.lead.clientName,
        jobType: _jobTitleController.text.trim(),
        estimatedCompletionDate: Value(normalizedDate),
      );
      await ref.read(jobsDaoProvider).createJob(companion);

      if (!mounted) return;
      Navigator.of(context).pop(_CreatedJobResult(jobId: jobId));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create job: $error')),
      );
      setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final dateLabel = _estimatedStartDate == null
        ? 'Select estimated start date'
        : DateFormat.yMMMMd().format(_estimatedStartDate!);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Job from This Lead', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              widget.lead.clientName,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jobTitleController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Job title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build_outlined),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _creating ? null : _pickEstimatedStartDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(dateLabel),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canConfirm ? _confirmCreateJob : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create Job'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSectionTitle extends StatelessWidget {
  const _CardSectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
