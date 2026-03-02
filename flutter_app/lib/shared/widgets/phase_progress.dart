import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PhaseProgress extends StatelessWidget {
  const PhaseProgress({
    super.key,
    required this.currentPhase,
    this.interactive = false,
    this.onPhaseSelected,
  });

  final String currentPhase;
  final bool interactive;
  final ValueChanged<String>? onPhaseSelected;

  static const _phases = [
    _Phase(value: 'demo', shortLabel: 'Demo', longLabel: 'Demo'),
    _Phase(value: 'rough', shortLabel: 'Rough', longLabel: 'Rough'),
    _Phase(
        value: 'electrical-plumbing',
        shortLabel: 'Elec',
        longLabel: 'Electrical/Plumbing'),
    _Phase(value: 'finishing', shortLabel: 'Finish', longLabel: 'Finishing'),
    _Phase(value: 'walkthrough', shortLabel: 'Walk', longLabel: 'Walkthrough'),
    _Phase(value: 'complete', shortLabel: 'Done', longLabel: 'Complete'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _phaseIndex(currentPhase);

    if (!interactive) {
      return Row(
        children: [
          for (var i = 0; i < _phases.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 6,
                decoration: BoxDecoration(
                  color: i <= currentIndex
                      ? AppColors.systemBlue
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _phases.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _phases[i].shortLabel,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tiny.copyWith(
                    color: i <= currentIndex
                        ? AppColors.systemBlue
                        : AppColors.mutedFg,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < _phases.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPhaseSelected == null
                      ? null
                      : () => onPhaseSelected!(_phases[i].value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i < currentIndex
                          ? AppColors.systemBlue
                          : i == currentIndex
                              ? AppColors.systemBlue.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  int _phaseIndex(String rawValue) {
    final normalized = rawValue.trim().toLowerCase().replaceAll('_', '-');
    final mapped = switch (normalized) {
      'electrical-plumbing' => 'electrical-plumbing',
      'electrical/plumbing' => 'electrical-plumbing',
      _ => normalized,
    };

    final index = _phases.indexWhere((phase) => phase.value == mapped);
    if (index >= 0) {
      return index;
    }
    return 0;
  }
}

class _Phase {
  const _Phase({
    required this.value,
    required this.shortLabel,
    required this.longLabel,
  });

  final String value;
  final String shortLabel;
  final String longLabel;
}
