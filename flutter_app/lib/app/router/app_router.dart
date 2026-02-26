import 'package:go_router/go_router.dart';

import '../../features/calls/daily_sweep_screen.dart';
import '../../features/followups/followups_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/leads/leads_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/leads',
    routes: [
      GoRoute(path: '/leads', builder: (_, __) => const LeadsScreen()),
      GoRoute(path: '/jobs', builder: (_, __) => const JobsScreen()),
      GoRoute(path: '/followups', builder: (_, __) => const FollowupsScreen()),
      GoRoute(path: '/daily-sweep', builder: (_, __) => const DailySweepScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
}
