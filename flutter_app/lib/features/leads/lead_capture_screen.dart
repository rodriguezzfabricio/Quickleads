import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_scaffold.dart';

class LeadCaptureScreen extends StatelessWidget {
  const LeadCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'New Lead',
      subtitle: 'Phase 2 placeholder: structured lead capture and quick text input land here.',
    );
  }
}
