import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/job_health_status.dart';
import '../../core/domain/job_phase.dart';
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
    final phaseLabel = JobPhase.fromDb(job.phase).displayLabel;
    final healthStatus = JobHealthStatus.fromDb(job.healthStatus);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: healthStatus.indicatorColor,
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
      trailing: _JobHealthChip(healthStatus: healthStatus),
      onTap: onTap ??
          () => context.push(
                AppRoutes.jobDetail.replaceFirst(':jobId', job.id),
              ),
    );
  }
}

class _JobHealthChip extends StatelessWidget {
  const _JobHealthChip({required this.healthStatus});

  final JobHealthStatus healthStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        healthStatus.displayLabel,
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
      backgroundColor: healthStatus.indicatorColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
