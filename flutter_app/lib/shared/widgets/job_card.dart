import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/domain/job_health_status.dart';
import '../../core/domain/job_phase.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'phase_progress.dart';
import 'status_pill.dart';

class JobCard extends StatefulWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  final LocalJob job;
  final VoidCallback? onTap;

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final status = JobHealthStatus.fromDb(widget.job.healthStatus);
    final tint = switch (status) {
      JobHealthStatus.onTrack => AppColors.onTrackTint,
      JobHealthStatus.needsAttention => AppColors.attentionTint,
      JobHealthStatus.behind => AppColors.behindTint,
    };
    final accent = switch (status) {
      JobHealthStatus.onTrack => AppColors.systemGreen,
      JobHealthStatus.needsAttention => AppColors.systemOrange,
      JobHealthStatus.behind => AppColors.systemRed,
    };

    final estimated = widget.job.estimatedCompletionDate;
    final estimatedText = estimated == null
        ? 'Est. TBD'
        : 'Est. ${DateFormat('MMM d, yyyy').format(estimated.toLocal())}';

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
                color: tint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(width: 4, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.clientName,
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.job.jobType,
                                  style: AppTextStyles.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusPill(status: _uiStatus(status)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PhaseProgress(
                            currentPhase:
                                JobPhase.fromDb(widget.job.phase).dbValue,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 12,
                                color: AppColors.mutedFg,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                estimatedText,
                                style:
                                    AppTextStyles.tiny.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  String _uiStatus(JobHealthStatus status) {
    return switch (status) {
      JobHealthStatus.onTrack => 'on-track',
      JobHealthStatus.needsAttention => 'needs-attention',
      JobHealthStatus.behind => 'behind',
    };
  }
}
