import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../auth/providers/auth_provider.dart';

class DailySweepScreen extends ConsumerStatefulWidget {
  const DailySweepScreen({
    super.key,
    this.forcedPlatform,
  });

  final String? forcedPlatform;

  @override
  ConsumerState<DailySweepScreen> createState() => _DailySweepScreenState();
}

class _DailySweepScreenState extends ConsumerState<DailySweepScreen> {
  int? _initialCallCount;
  String? _updatingCallId;

  bool get _isIOS {
    final forced = widget.forcedPlatform;
    if (forced == 'ios') {
      return true;
    }
    if (forced == 'android') {
      return false;
    }
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  Future<void> _saveAsLead(LocalCallLog call) async {
    if (_updatingCallId != null) {
      return;
    }

    setState(() => _updatingCallId = call.id);
    try {
      await ref
          .read(callLogsDaoProvider)
          .updateDisposition(call.id, 'saved_as_lead');
      if (!mounted) {
        return;
      }
      final phone = Uri.encodeQueryComponent(call.phoneE164);
      context.push('${AppRoutes.leadCapture}?phone=$phone');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save call as lead: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingCallId = null);
      }
    }
  }

  Future<void> _skip(LocalCallLog call) async {
    if (_updatingCallId != null) {
      return;
    }

    setState(() => _updatingCallId = call.id);
    try {
      await ref.read(callLogsDaoProvider).updateDisposition(call.id, 'skipped');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not skip call: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingCallId = null);
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes min ${remaining.toString().padLeft(2, '0')} sec';
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final unknownCallsAsync = ref.watch(unknownCallsProvider(orgId));

    return Scaffold(
      body: SafeArea(
        child: unknownCallsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading calls: $error'),
          ),
          data: (unknownCalls) {
            _initialCallCount ??= unknownCalls.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(AppRoutes.leads),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Leads',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Today's Calls — ${DateFormat('MMM d, yyyy').format(DateTime.now())}",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${unknownCalls.length} calls from numbers not in your leads',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 16),
                if (unknownCalls.isNotEmpty)
                  ...unknownCalls.map(
                    (call) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _UnknownCallCard(
                        call: call,
                        showDurationMeta: !_isIOS,
                        isUpdating: _updatingCallId == call.id,
                        onSaveAsLead: () => _saveAsLead(call),
                        onSkip: () => _skip(call),
                        formatDuration: _formatDuration,
                      ),
                    ),
                  ),
                if (unknownCalls.isEmpty && (_initialCallCount ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTokens.glassBorder),
                      color: AppTokens.glassElevated,
                    ),
                    child: Text(
                      'All caught up! ✓',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (unknownCalls.isEmpty && (_initialCallCount ?? 0) == 0)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTokens.glassBorder),
                      color: AppTokens.glassElevated,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'No new calls today. You\'re all set.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.go(AppRoutes.leads),
                          child: const Text('Dismiss'),
                        ),
                      ],
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

class _UnknownCallCard extends StatelessWidget {
  const _UnknownCallCard({
    required this.call,
    required this.showDurationMeta,
    required this.isUpdating,
    required this.onSaveAsLead,
    required this.onSkip,
    required this.formatDuration,
  });

  final LocalCallLog call;
  final bool showDurationMeta;
  final bool isUpdating;
  final VoidCallback onSaveAsLead;
  final VoidCallback onSkip;
  final String Function(int seconds) formatDuration;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('h:mm a').format(call.startedAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTokens.glassBorder),
        color: AppTokens.glassElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(call.phoneE164, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          if (showDurationMeta) ...[
            const SizedBox(height: 4),
            Text(
              formatDuration(call.durationSec),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: isUpdating ? null : onSaveAsLead,
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save as Lead'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isUpdating ? null : onSkip,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
