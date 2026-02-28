import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';

// ── Status options ────────────────────────────────────────────────────────────

const _kStatusOptions = [
  ('new_callback', 'New / Callback'),
  ('quoted', 'Quoted'),
  ('won', 'Won'),
  ('cold', 'Cold'),
  ('lost', 'Lost'),
];

const _uuid = Uuid();

// ── LeadDetailScreen ──────────────────────────────────────────────────────────

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

    // Watch the single lead reactively via DAO stream.
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

// ── Riverpod provider (scoped to this file) ───────────────────────────────────

final _leadByIdProvider = StreamProvider.family<LocalLead?, String>((ref, id) {
  return ref.watch(leadsDaoProvider).watchLeadById(id);
});

// ── Body ──────────────────────────────────────────────────────────────────────

class _LeadDetailBody extends ConsumerStatefulWidget {
  const _LeadDetailBody({required this.lead});
  final LocalLead lead;

  @override
  ConsumerState<_LeadDetailBody> createState() => _LeadDetailBodyState();
}

class _LeadDetailBodyState extends ConsumerState<_LeadDetailBody> {
  late String _pendingStatus;
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _pendingStatus = widget.lead.status;
  }

  @override
  void didUpdateWidget(_LeadDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync if the DB stream fires a new value.
    if (widget.lead.status != oldWidget.lead.status && !_updatingStatus) {
      _pendingStatus = widget.lead.status;
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    if (newStatus == widget.lead.status) return;

    final shouldProceed = await _confirmStatusChange(newStatus);
    if (!shouldProceed || !mounted) {
      return;
    }

    final previousStatus = widget.lead.status;
    setState(() {
      _pendingStatus = newStatus;
      _updatingStatus = true;
    });

    try {
      await ref.read(leadsDaoProvider).updateLeadStatus(
            widget.lead.id,
            newStatus,
            widget.lead.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update lead status: $error')),
      );
      setState(() => _pendingStatus = previousStatus);
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  Future<bool> _confirmStatusChange(String newStatus) async {
    if (newStatus != 'won' && newStatus != 'lost') {
      return true;
    }

    final (title, message, confirmLabel) = switch (newStatus) {
      'won' => (
          'Mark as Won?',
          'Mark as Won? This will start the follow-up sequence.',
          'Mark Won',
        ),
      'lost' => (
          'Mark as Lost?',
          'Mark as Lost? This will stop follow-ups.',
          'Mark Lost',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lead = widget.lead;
    final dateFormat = DateFormat.yMMMMd();
    final jobForLeadAsync =
        lead.status == 'won' ? ref.watch(jobForLeadProvider(lead.id)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(lead.clientName, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Status Card ───────────────────────────────────────────
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
                        Text('Lead Status',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _updatingStatus
                        ? const Center(
                            child: SizedBox(
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : SegmentedButton<String>(
                            segments: _kStatusOptions
                                .map((s) => ButtonSegment<String>(
                                      value: s.$1,
                                      label: Text(s.$2),
                                    ))
                                .toList(),
                            selected: {_pendingStatus},
                            onSelectionChanged: (sel) =>
                                _changeStatus(sel.first),
                            style: SegmentedButton.styleFrom(
                              textStyle: theme.textTheme.labelSmall,
                            ),
                          ),
                  ],
                ),
              ),
            ),

            if (lead.status == 'won') ...[
              const SizedBox(height: 16),
              _WonLeadConversionCard(
                lead: lead,
                jobForLeadAsync: jobForLeadAsync!,
                onStartJob: () => _openConvertToJobSheet(lead),
              ),
            ],

            const SizedBox(height: 16),

            // ── Contact Info Card ─────────────────────────────────────
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
                          value: lead.phoneE164!),
                    ],
                    if (lead.email != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: lead.email!),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Job Details Card ──────────────────────────────────────
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
                        value: lead.jobType),
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

            if (lead.notes != null && lead.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              // ── Notes Card ────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardSectionTitle(
                          icon: Icons.notes_outlined, label: 'Notes'),
                      const SizedBox(height: 12),
                      Text(lead.notes!, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Timestamps ────────────────────────────────────────────
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
                        Text('Pending sync',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
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

// ── Small helper widgets ──────────────────────────────────────────────────────

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
        Text(label,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary)),
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
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
