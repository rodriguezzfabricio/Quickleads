import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Settings',
      subtitle: 'Phase 6: onboarding, CSV import, and messaging settings land here.',
    );
  }
}
