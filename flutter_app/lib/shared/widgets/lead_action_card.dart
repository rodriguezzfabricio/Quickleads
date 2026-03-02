import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_card.dart';

enum LeadActionVariant { urgent, followingUp, won }

class LeadActionCard extends StatefulWidget {
  const LeadActionCard({
    super.key,
    required this.lead,
    required this.variant,
    this.onTap,
    this.onCall,
    this.onEstimateSent,
    this.followupSteps,
    this.elapsedText,
    this.busy = false,
  });

  final LocalLead lead;
  final LeadActionVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onEstimateSent;
  final List<bool>? followupSteps;
  final String? elapsedText;
  final bool busy;

  @override
  State<LeadActionCard> createState() => _LeadActionCardState();
}

class _LeadActionCardState extends State<LeadActionCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final accent = switch (widget.variant) {
      LeadActionVariant.urgent => AppColors.systemRed,
      LeadActionVariant.followingUp => AppColors.systemBlue,
      LeadActionVariant.won => AppColors.systemGreen,
    };

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) => setState(() => _scale = 1),
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(width: 4, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: switch (widget.variant) {
                        LeadActionVariant.urgent => _UrgentContent(
                            lead: widget.lead,
                            elapsedText: widget.elapsedText,
                            onCall: widget.onCall,
                            onEstimateSent: widget.onEstimateSent,
                            busy: widget.busy,
                          ),
                        LeadActionVariant.followingUp => _FollowingUpContent(
                            lead: widget.lead,
                            onCall: widget.onCall,
                            followupSteps: widget.followupSteps ??
                                const [false, false, false],
                          ),
                        LeadActionVariant.won => _WonContent(lead: widget.lead),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgentContent extends StatelessWidget {
  const _UrgentContent({
    required this.lead,
    this.elapsedText,
    this.onCall,
    this.onEstimateSent,
    required this.busy,
  });

  final LocalLead lead;
  final String? elapsedText;
  final VoidCallback? onCall;
  final VoidCallback? onEstimateSent;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lead.clientName,
                style: AppTextStyles.h3
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              'URGENT',
              style: AppTextStyles.badge.copyWith(
                color: AppColors.systemRed,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(lead.jobType, style: AppTextStyles.secondary),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, size: 13, color: AppColors.mutedFg),
            const SizedBox(width: 6),
            Text(elapsedText ?? 'just now',
                style: AppTextStyles.tiny.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone_outlined, size: 16),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.systemRed.withValues(alpha: 0.9),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.h4
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            label: Text('Call ${lead.phoneE164 ?? ''}'),
          ),
        ),
        if (onEstimateSent != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : onEstimateSent,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.systemYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: AppTextStyles.h4
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Estimate Sent?'),
            ),
          ),
        ],
      ],
    );
  }
}

class _FollowingUpContent extends StatelessWidget {
  const _FollowingUpContent({
    required this.lead,
    required this.onCall,
    required this.followupSteps,
  });

  final LocalLead lead;
  final VoidCallback? onCall;
  final List<bool> followupSteps;

  @override
  Widget build(BuildContext context) {
    final sentCount = followupSteps.where((sent) => sent).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lead.clientName,
                style: AppTextStyles.h3
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              'Day $sentCount of 10',
              style: AppTextStyles.badge.copyWith(color: AppColors.systemBlue),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(lead.jobType, style: AppTextStyles.secondary),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 12,
          color: AppColors.glassBase,
          child: Column(
            children: [
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: followupSteps[i]
                                    ? AppColors.systemBlue
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: followupSteps[i]
                                ? AppColors.systemBlue
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Day 2', style: AppTextStyles.tiny),
                  Text('Day 5', style: AppTextStyles.tiny),
                  Text('Day 10', style: AppTextStyles.tiny),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassProminent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone_outlined,
                  size: 16, color: AppColors.foreground),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.foreground,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              label: Text(
                lead.phoneE164 ?? 'No phone',
                style: AppTextStyles.h4.copyWith(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WonContent extends StatelessWidget {
  const _WonContent({required this.lead});

  final LocalLead lead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lead.clientName,
                style: AppTextStyles.h3
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 12, color: AppColors.systemGreen),
                const SizedBox(width: 4),
                Text(
                  'Won',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.systemGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(lead.jobType, style: AppTextStyles.secondary),
      ],
    );
  }
}
