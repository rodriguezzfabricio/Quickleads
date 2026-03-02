import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.status,
    this.text,
  });

  final String status;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final normalized = _normalize(status);
    final style = _statusStyle(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text ?? style.label,
        style: AppTextStyles.badge.copyWith(
          fontWeight: FontWeight.w600,
          color: style.foreground,
        ),
      ),
    );
  }

  String _normalize(String raw) {
    final value = raw.trim().toLowerCase().replaceAll('_', '-');
    return switch (value) {
      'new-callback' || 'new' => 'call-back-now',
      'estimate-sent' || 'quoted' => 'estimate-sent',
      'green' || 'ontrack' => 'on-track',
      'yellow' || 'needsattention' => 'needs-attention',
      'red' || 'behindschedule' => 'behind',
      _ => value,
    };
  }
}

class _StatusPillStyle {
  const _StatusPillStyle({
    required this.background,
    required this.foreground,
    required this.label,
  });

  final Color background;
  final Color foreground;
  final String label;
}

_StatusPillStyle _statusStyle(String status) {
  return switch (status) {
    'call-back-now' => const _StatusPillStyle(
        background: Color(0x33FF453A),
        foreground: AppColors.systemRed,
        label: 'Callback',
      ),
    'estimate-sent' => const _StatusPillStyle(
        background: Color(0x33FF9F0A),
        foreground: AppColors.systemOrange,
        label: 'Estimate',
      ),
    'won' => const _StatusPillStyle(
        background: Color(0x334A9E7E),
        foreground: AppColors.systemGreen,
        label: 'Won',
      ),
    'cold' => _StatusPillStyle(
        background: AppColors.mutedFg.withValues(alpha: 0.15),
        foreground: AppColors.mutedFg,
        label: 'Cold',
      ),
    'on-track' => const _StatusPillStyle(
        background: Color(0x334A9E7E),
        foreground: AppColors.systemGreen,
        label: 'On Track',
      ),
    'needs-attention' => const _StatusPillStyle(
        background: Color(0x33FF9F0A),
        foreground: AppColors.systemOrange,
        label: 'Needs Attention',
      ),
    'behind' => const _StatusPillStyle(
        background: Color(0x33FF453A),
        foreground: AppColors.systemRed,
        label: 'Behind',
      ),
    _ => _StatusPillStyle(
        background: AppColors.mutedFg.withValues(alpha: 0.15),
        foreground: AppColors.mutedFg,
        label: status,
      ),
  };
}
