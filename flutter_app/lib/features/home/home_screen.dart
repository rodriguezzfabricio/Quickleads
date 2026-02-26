import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Dashboard',
      subtitle: 'Phase 0 placeholder: Home metrics, reminders, and quick navigation live here.',
    );
  }
}
