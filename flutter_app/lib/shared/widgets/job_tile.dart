import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';

/// Reusable list tile for a job, matching the [LeadTile] pattern.
class JobTile extends StatelessWidget {
  const JobTile({
    super.key,
    required this.job,
    this.onTap,
  });

  final LocalJob job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updated = DateFormat.MMMd().format(job.updatedAt.toLocal());
    final phaseLabel = _phaseDisplayName(job.phase);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _healthColor(job.healthStatus, theme),
        foregroundColor: theme.colorScheme.onPrimary,
        child: Text(
          job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : '?',
        ),
      ),
      title: Text(
        job.clientName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${job.jobType}  ·  $phaseLabel  ·  $updated',
        style: theme.textTheme.bodySmall,
      ),
      trailing: _JobHealthChip(healthStatus: job.healthStatus),
      onTap: onTap ??
          () => context.push(
                AppRoutes.jobDetail.replaceFirst(':jobId', job.id),
              ),
    );
  }

  Color _healthColor(String healthStatus, ThemeData theme) {
    return switch (healthStatus) {
      'green' => Colors.green.shade600,
      'yellow' => Colors.orange.shade600,
      'red' => theme.colorScheme.error,
      _ => theme.colorScheme.tertiary,
    };
  }
}

String _phaseDisplayName(String phase) {
  return switch (phase) {
    'demo' => 'Demo',
    'scheduled' => 'Scheduled',
    'in_progress' => 'In Progress',
    'punch_list' => 'Punch List',
    'completed' => 'Completed',
    _ => phase,
  };
}

class _JobHealthChip extends StatelessWidget {
  const _JobHealthChip({required this.healthStatus});

  final String healthStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (healthStatus) {
      'green' => ('Active', Colors.green.shade600),
      'yellow' => ('On Hold', Colors.orange.shade600),
      'red' => ('Completed', theme.colorScheme.error),
      _ => (healthStatus, theme.colorScheme.tertiary),
    };
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
