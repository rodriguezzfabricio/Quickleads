import 'package:flutter/material.dart';

import '../../core/storage/app_database.dart';
import 'job_card.dart';

class JobTile extends StatelessWidget {
  const JobTile({
    super.key,
    required this.job,
    this.onTap,
  });

  final LocalJob job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return JobCard(job: job, onTap: onTap);
  }
}
