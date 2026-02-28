import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';

class LeadTile extends StatelessWidget {
  const LeadTile({
    super.key,
    required this.lead,
    this.onTap,
  });

  final LocalLead lead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updated = DateFormat.MMMd().format(lead.updatedAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor(lead.status, theme),
        foregroundColor: theme.colorScheme.onPrimary,
        child: Text(
          lead.clientName.isNotEmpty ? lead.clientName[0].toUpperCase() : '?',
        ),
      ),
      title: Text(
        lead.clientName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${lead.jobType}  ·  $updated',
        style: theme.textTheme.bodySmall,
      ),
      trailing: _LeadStatusChip(status: lead.status),
      onTap: onTap ??
          () => context.push(
                AppRoutes.leadDetail.replaceFirst(':leadId', lead.id),
              ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    final cs = theme.colorScheme;
    return switch (status) {
      'won' => Colors.green.shade600,
      'quoted' || 'estimate_sent' => cs.primary,
      'lost' => cs.error,
      'cold' => Colors.blueGrey,
      _ => cs.tertiary,
    };
  }
}

class _LeadStatusChip extends StatelessWidget {
  const _LeadStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (status) {
      'new_callback' => 'New',
      'quoted' || 'estimate_sent' => 'Quoted',
      'won' => 'Won',
      'cold' => 'Cold',
      'lost' => 'Lost',
      _ => status,
    };
    final color = switch (status) {
      'won' => Colors.green.shade600,
      'quoted' || 'estimate_sent' => theme.colorScheme.primary,
      'lost' => theme.colorScheme.error,
      'cold' => Colors.blueGrey,
      _ => theme.colorScheme.tertiary,
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
