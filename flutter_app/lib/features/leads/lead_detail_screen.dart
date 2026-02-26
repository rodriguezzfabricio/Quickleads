import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_scaffold.dart';

class LeadDetailScreen extends StatelessWidget {
  const LeadDetailScreen({
    super.key,
    this.leadId,
  });

  final String? leadId;

  @override
  Widget build(BuildContext context) {
    final subtitle = leadId == null || leadId!.isEmpty
        ? 'Phase 2 placeholder: lead profile actions, follow-up state, and status transitions land here.'
        : 'Phase 2 placeholder: lead profile actions for $leadId land here.';

    return PlaceholderScaffold(
      title: 'Lead Detail',
      subtitle: subtitle,
    );
  }
}
