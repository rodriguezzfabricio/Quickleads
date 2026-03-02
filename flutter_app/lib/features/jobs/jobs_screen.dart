import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/domain/job_health_status.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/job_card.dart';

const _filters = [
  ('all', 'All'),
  ('yellow', 'Attention'),
  ('red', 'Behind'),
];

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';

    if (orgId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final jobsAsync = ref.watch(jobsByOrgProvider(orgId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: jobsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error loading jobs: $error'),
          ),
          data: (jobs) {
            final filtered = _applyFilter(jobs, _filter);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              children: [
                _stagger(0, Text('Jobs', style: AppTextStyles.h1)),
                const SizedBox(height: 12),
                _stagger(
                  1,
                  _FilterStrip(
                    selectedFilter: _filter,
                    onSelectFilter: (value) {
                      setState(() => _filter = value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Text(
                      'No jobs found',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3.copyWith(fontSize: 17),
                    ),
                  )
                else
                  for (var i = 0; i < filtered.length; i++) ...[
                    _stagger(
                      i + 2,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: JobCard(
                          job: filtered[i],
                          onTap: () => context.push(
                            AppRoutes.jobDetail
                                .replaceFirst(':jobId', filtered[i].id),
                          ),
                        ),
                      ),
                    ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stagger(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 40)),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final delayed = ((value - (index * 0.03)).clamp(0, 1)).toDouble();
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, (1 - delayed) * 8),
            child: child,
          ),
        );
      },
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.glassElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (final filter in _filters)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelectFilter(filter.$1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: selectedFilter == filter.$1
                        ? AppColors.glassProminent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter.$2,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      letterSpacing: 0,
                      color: selectedFilter == filter.$1
                          ? AppColors.foreground
                          : AppColors.mutedFg,
                      fontWeight: selectedFilter == filter.$1
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

List<LocalJob> _applyFilter(List<LocalJob> jobs, String filter) {
  if (filter == 'all') return jobs;
  return jobs.where((job) {
    return JobHealthStatus.fromDb(job.healthStatus).dbValue == filter;
  }).toList();
}
