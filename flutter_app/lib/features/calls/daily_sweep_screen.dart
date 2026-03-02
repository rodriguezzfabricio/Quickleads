import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

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
    if (forced == 'ios') return true;
    if (forced == 'android') return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  Future<void> _saveAsLead(LocalCallLog call) async {
    if (_updatingCallId != null) return;

    setState(() => _updatingCallId = call.id);
    try {
      await ref
          .read(callLogsDaoProvider)
          .updateDisposition(call.id, 'saved_as_lead');
      if (!mounted) return;
      final phone = Uri.encodeQueryComponent(call.phoneE164);
      context.push('${AppRoutes.leadCapture}?phone=$phone');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save call as lead: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingCallId = null);
    }
  }

  Future<void> _skip(LocalCallLog call) async {
    if (_updatingCallId != null) return;

    setState(() => _updatingCallId = call.id);
    try {
      await ref.read(callLogsDaoProvider).updateDisposition(call.id, 'skipped');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not skip call: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingCallId = null);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: unknownCallsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading calls: $error'),
          ),
          data: (unknownCalls) {
            _initialCallCount ??= unknownCalls.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(AppRoutes.leads),
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 24,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Today's Calls — ${DateFormat('MMM d, yyyy').format(DateTime.now())}",
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 6),
                Text(
                  '${unknownCalls.length} calls from numbers not in your leads',
                  style: AppTextStyles.secondary,
                ),
                const SizedBox(height: 14),
                if (unknownCalls.isNotEmpty)
                  for (final call in unknownCalls)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _UnknownCallCard(
                          key: ValueKey(call.id),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'All caught up! ✓',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3.copyWith(fontSize: 17),
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
    super.key,
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

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(call.phoneE164, style: AppTextStyles.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(timeLabel,
              style: AppTextStyles.secondary.copyWith(fontSize: 14)),
          if (showDurationMeta) ...[
            const SizedBox(height: 2),
            Text(
              formatDuration(call.durationSec),
              style: AppTextStyles.tiny.copyWith(fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: isUpdating ? null : onSaveAsLead,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.systemBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.h4
                        .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
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
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  decoration: BoxDecoration(
                    color: AppColors.glassElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: TextButton(
                    onPressed: isUpdating ? null : onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedFg,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 15,
                        color: AppColors.mutedFg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
