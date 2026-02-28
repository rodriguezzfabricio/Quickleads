import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';

// ── Phase progression order ───────────────────────────────────────────────────

const _kPhases = [
  ('demo', 'Demo'),
  ('scheduled', 'Scheduled'),
  ('in_progress', 'In Progress'),
  ('punch_list', 'Punch List'),
  ('completed', 'Completed'),
];

const _kHealthOptions = [
  ('green', 'Active'),
  ('yellow', 'On Hold'),
  ('red', 'Completed'),
];

// ── JobDetailScreen ───────────────────────────────────────────────────────────

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, this.jobId});

  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jobId == null || jobId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Detail')),
        body: const Center(child: Text('No job ID provided.')),
      );
    }

    final jobAsync = ref.watch(jobByIdProvider(jobId!));

    return jobAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Job')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Job')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (job) {
        if (job == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Job')),
            body: const Center(child: Text('Job not found or was deleted.')),
          );
        }
        return _JobDetailBody(job: job);
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _JobDetailBody extends ConsumerStatefulWidget {
  const _JobDetailBody({required this.job});
  final LocalJob job;

  @override
  ConsumerState<_JobDetailBody> createState() => _JobDetailBodyState();
}

class _JobDetailBodyState extends ConsumerState<_JobDetailBody> {
  late String _pendingHealthStatus;
  bool _updatingHealth = false;
  bool _updatingPhase = false;

  @override
  void initState() {
    super.initState();
    _pendingHealthStatus = widget.job.healthStatus;
  }

  @override
  void didUpdateWidget(_JobDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.job.healthStatus != oldWidget.job.healthStatus &&
        !_updatingHealth) {
      _pendingHealthStatus = widget.job.healthStatus;
    }
  }

  // ── Health status mutation ────────────────────────────────────────

  Future<void> _changeHealthStatus(String newStatus) async {
    if (newStatus == widget.job.healthStatus) return;

    if (newStatus == 'red') {
      final confirmed = await _confirmDialog(
        title: 'Mark as Completed?',
        message: 'This will mark the job as completed.',
        confirmLabel: 'Complete',
      );
      if (!confirmed || !mounted) return;
    }

    final prev = widget.job.healthStatus;
    setState(() {
      _pendingHealthStatus = newStatus;
      _updatingHealth = true;
    });

    try {
      await ref.read(jobsDaoProvider).updateJobHealthStatus(
            widget.job.id,
            newStatus,
            widget.job.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update status: $error')),
      );
      setState(() => _pendingHealthStatus = prev);
    } finally {
      if (mounted) setState(() => _updatingHealth = false);
    }
  }

  // ── Phase progression mutation ────────────────────────────────────

  Future<void> _advancePhase() async {
    final currentIndex =
        _kPhases.indexWhere((p) => p.$1 == widget.job.phase);
    if (currentIndex == -1 || currentIndex >= _kPhases.length - 1) return;

    final nextPhase = _kPhases[currentIndex + 1];
    final confirmed = await _confirmDialog(
      title: 'Advance Phase?',
      message: 'Move this job from "${_kPhases[currentIndex].$2}" '
          'to "${nextPhase.$2}"?',
      confirmLabel: 'Advance',
    );
    if (!confirmed || !mounted) return;

    setState(() => _updatingPhase = true);

    try {
      await ref.read(jobsDaoProvider).updateJobPhase(
            widget.job.id,
            nextPhase.$1,
            widget.job.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not advance phase: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingPhase = false);
    }
  }

  Future<void> _revertPhase() async {
    final currentIndex =
        _kPhases.indexWhere((p) => p.$1 == widget.job.phase);
    if (currentIndex <= 0) return;

    final prevPhase = _kPhases[currentIndex - 1];
    final confirmed = await _confirmDialog(
      title: 'Revert Phase?',
      message: 'Move this job back from "${_kPhases[currentIndex].$2}" '
          'to "${prevPhase.$2}"?',
      confirmLabel: 'Revert',
    );
    if (!confirmed || !mounted) return;

    setState(() => _updatingPhase = true);

    try {
      await ref.read(jobsDaoProvider).updateJobPhase(
            widget.job.id,
            prevPhase.$1,
            widget.job.version,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not revert phase: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingPhase = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
    return confirmed == true;
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = widget.job;
    final dateFormat = DateFormat.yMMMMd();
    final currentPhaseIndex = _kPhases.indexWhere((p) => p.$1 == job.phase);
    final isLastPhase = currentPhaseIndex == _kPhases.length - 1;
    final isFirstPhase = currentPhaseIndex <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(job.clientName, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Health Status Card ────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart_outlined,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Job Status',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _updatingHealth
                        ? const Center(
                            child: SizedBox(
                              height: 36,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : SegmentedButton<String>(
                            segments: _kHealthOptions
                                .map((s) => ButtonSegment<String>(
                                      value: s.$1,
                                      label: Text(s.$2),
                                    ))
                                .toList(),
                            selected: {_pendingHealthStatus},
                            onSelectionChanged: (sel) =>
                                _changeHealthStatus(sel.first),
                            style: SegmentedButton.styleFrom(
                              textStyle: theme.textTheme.labelSmall,
                            ),
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Phase Progression Card ────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardSectionTitle(
                        icon: Icons.trending_up_outlined, label: 'Phase'),
                    const SizedBox(height: 16),
                    _PhaseProgressRow(
                      phases: _kPhases,
                      currentPhaseIndex: currentPhaseIndex,
                    ),
                    const SizedBox(height: 16),
                    if (_updatingPhase)
                      const Center(
                        child: SizedBox(
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      Row(
                        children: [
                          if (!isFirstPhase)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _revertPhase,
                                icon: const Icon(Icons.undo_outlined, size: 18),
                                label: const Text('Revert'),
                              ),
                            ),
                          if (!isFirstPhase && !isLastPhase)
                            const SizedBox(width: 12),
                          if (!isLastPhase)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _advancePhase,
                                icon: const Icon(Icons.arrow_forward_outlined,
                                    size: 18),
                                label: const Text('Advance'),
                              ),
                            ),
                          if (isLastPhase && isFirstPhase)
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: null,
                                child: Text(
                                  currentPhaseIndex == _kPhases.length - 1
                                      ? 'All phases complete'
                                      : 'Unknown phase',
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Client Info Card ──────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardSectionTitle(
                        icon: Icons.person_outline, label: 'Client'),
                    const SizedBox(height: 12),
                    _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        value: job.clientName),
                    const Divider(height: 24),
                    _InfoRow(
                        icon: Icons.build_outlined,
                        label: 'Job Type',
                        value: job.jobType),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Schedule Card ─────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardSectionTitle(
                        icon: Icons.calendar_month_outlined,
                        label: 'Schedule'),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Est. Completion',
                      value: job.estimatedCompletionDate != null
                          ? dateFormat
                              .format(job.estimatedCompletionDate!.toLocal())
                          : '—',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Timestamps ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Created ${dateFormat.format(job.createdAt.toLocal())}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ),
                  if (job.needsSync)
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

// ── Phase progress row ────────────────────────────────────────────────────────

class _PhaseProgressRow extends StatelessWidget {
  const _PhaseProgressRow({
    required this.phases,
    required this.currentPhaseIndex,
  });

  final List<(String, String)> phases;
  final int currentPhaseIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(phases.length * 2 - 1, (i) {
        // Even indices → phase dot+label, odd → connector line.
        if (i.isOdd) {
          final phaseBeforeIndex = i ~/ 2;
          final isDone = phaseBeforeIndex < currentPhaseIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          );
        }

        final phaseIndex = i ~/ 2;
        final isCompleted = phaseIndex < currentPhaseIndex;
        final isCurrent = phaseIndex == currentPhaseIndex;
        final label = phases[phaseIndex].$2;

        final Color dotColor;
        if (isCompleted) {
          dotColor = theme.colorScheme.primary;
        } else if (isCurrent) {
          dotColor = theme.colorScheme.primary;
        } else {
          dotColor = theme.colorScheme.outlineVariant;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCurrent ? 20 : 14,
              height: isCurrent ? 20 : 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent ? dotColor : Colors.transparent,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: isCompleted
                  ? Icon(Icons.check,
                      size: 10, color: theme.colorScheme.onPrimary)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCompleted || isCurrent
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.outline,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }),
    );
  }
}

// ── Small helper widgets (matching lead_detail_screen pattern) ─────────────────

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
