import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

final _leadByIdProvider =
    StreamProvider.family<LocalLead?, String>((ref, id) {
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

    setState(() {
      _pendingStatus = newStatus;
      _updatingStatus = true;
    });

    await ref.read(leadsDaoProvider).updateLeadStatus(
          widget.lead.id,
          newStatus,
          widget.lead.version,
        );

    if (mounted) setState(() => _updatingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lead = widget.lead;
    final dateFormat = DateFormat.yMMMMd();

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

            const SizedBox(height: 16),

            // ── Contact Info Card ─────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardSectionTitle(icon: Icons.person_outline, label: 'Contact'),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.badge_outlined, label: 'Name', value: lead.clientName),
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
                    _CardSectionTitle(icon: Icons.construction_outlined, label: 'Job Details'),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.build_outlined, label: 'Job Type', value: lead.jobType),
                    if (lead.estimateSentAt != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Estimate Sent',
                        value: dateFormat.format(lead.estimateSentAt!.toLocal()),
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
                      _CardSectionTitle(icon: Icons.notes_outlined, label: 'Notes'),
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
