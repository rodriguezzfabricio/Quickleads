import 'package:flutter/material.dart';

import '../../core/domain/lead_status_mapper.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_card.dart';
import 'status_pill.dart';

class LeadFollowupStep {
  const LeadFollowupStep({
    required this.day,
    required this.sent,
  });

  final int day;
  final bool sent;
}

class LeadCard extends StatefulWidget {
  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onEstimateSent,
    this.expanded = false,
    this.onViewProfile,
    this.onAddAsClient,
    this.followupSteps,
  });

  final LocalLead lead;
  final VoidCallback? onTap;
  final VoidCallback? onEstimateSent;
  final bool expanded;
  final VoidCallback? onViewProfile;
  final VoidCallback? onAddAsClient;
  final List<LeadFollowupStep>? followupSteps;

  @override
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final canonical = LeadStatusMapper.canonicalize(widget.lead.status);
    final phone = widget.lead.phoneE164?.trim().isNotEmpty == true
        ? widget.lead.phoneE164!
        : 'No phone';

    final followupSteps = widget.followupSteps ??
        const [
          LeadFollowupStep(day: 2, sent: false),
          LeadFollowupStep(day: 5, sent: false),
          LeadFollowupStep(day: 10, sent: false),
        ];

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) => setState(() => _scale = 1),
        onTap: widget.onTap,
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lead.clientName,
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(widget.lead.jobType,
                                style: AppTextStyles.secondary),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 13,
                                  color: AppColors.mutedFg,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  phone,
                                  style:
                                      AppTextStyles.tiny.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(status: _uiStatus(canonical)),
                    ],
                  ),
                  if (canonical == LeadStatusMapper.callbackDb &&
                      widget.onEstimateSent != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.onEstimateSent,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.systemYellow,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.h4.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Estimate Sent?'),
                      ),
                    ),
                  ],
                  if (widget.lead.followupState == 'active' ||
                      canonical == LeadStatusMapper.estimateDb) ...[
                    const SizedBox(height: 12),
                    for (final step in followupSteps) ...[
                      Row(
                        children: [
                          Icon(
                            step.sent ? Icons.check_circle : Icons.schedule,
                            size: 10,
                            color: step.sent
                                ? AppColors.systemBlue
                                : AppColors.mutedFg,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Follow-up ${_indexForDay(step.day)}: Day ${step.day} ${step.sent ? '✓ Sent' : '⏳ Scheduled'}',
                            style: AppTextStyles.tiny.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      if (step != followupSteps.last) const SizedBox(height: 4),
                    ],
                  ],
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: widget.expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MiniAction(
                              label: 'View Profile',
                              onTap: widget.onViewProfile,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MiniAction(
                              label: 'Add as Client',
                              onTap: widget.onAddAsClient,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  int _indexForDay(int day) {
    return switch (day) {
      2 => 1,
      5 => 2,
      10 => 3,
      _ => 1,
    };
  }

  String _uiStatus(String canonical) {
    return switch (canonical) {
      LeadStatusMapper.callbackDb => 'call-back-now',
      LeadStatusMapper.estimateDb => 'estimate-sent',
      LeadStatusMapper.wonDb => 'won',
      LeadStatusMapper.coldDb => 'cold',
      _ => canonical,
    };
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.glassProminent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.h4.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
