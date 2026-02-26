import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_scaffold.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({
    super.key,
    this.jobId,
  });

  final String? jobId;

  @override
  Widget build(BuildContext context) {
    final subtitle = jobId == null || jobId!.isEmpty
        ? 'Phase 4 placeholder: phase progression, notes, and photo actions land here.'
        : 'Phase 4 placeholder: job controls for $jobId land here.';

    return PlaceholderScaffold(
      title: 'Job Detail',
      subtitle: subtitle,
    );
  }
}
