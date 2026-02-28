import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/confirm_email_screen.dart';
import '../../features/auth/magic_link_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/calls/daily_sweep_screen.dart';
import '../../features/clients/client_detail_screen.dart';
import '../../features/clients/clients_screen.dart';
import '../../features/followups/followup_settings_screen.dart';
import '../../features/followups/followups_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/import/data_import_screen.dart';
import '../../features/jobs/job_detail_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/leads/lead_capture_screen.dart';
import '../../features/leads/lead_detail_screen.dart';
import '../../features/leads/leads_screen.dart';
import '../../features/onboarding/workspace_setup_screen.dart';
import '../../features/projects/project_creation_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRoutes {
  static const home = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const magicLink = '/magic-link';
  static const confirmEmail = '/confirm-email';
  static const workspaceSetup = '/onboarding/workspace-setup';
  static const leads = '/leads';
  static const leadCapture = '/lead-capture';
  static const leadDetail = '/leads/:leadId';
  static const jobs = '/jobs';
  static const jobDetail = '/jobs/:jobId';
  static const clients = '/clients';
  static const clientCreate = '/clients/new';
  static const clientDetail = '/clients/:clientId';
  static const projectCreate = '/projects/new';
  static const dailySweepReview = '/daily-sweep-review';
  static const followups = '/followups';
  static const followupSettings = '/follow-up-settings';
  static const onboarding = '/onboarding';
  static const settings = '/settings';
}

bool _isAuthRoute(String location) {
  return location == AppRoutes.signIn ||
      location == AppRoutes.signUp ||
      location == AppRoutes.magicLink ||
      location == AppRoutes.confirmEmail;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (_, state) {
      if (authAsync.isLoading) {
        return null;
      }

      final authState =
          authAsync.valueOrNull ?? const AppAuthState.unauthenticated();
      final location = state.matchedLocation;
      final isOnAuthRoute = _isAuthRoute(location);
      final isWorkspaceSetup = location == AppRoutes.workspaceSetup;

      switch (authState.status) {
        case AppAuthStatus.loading:
          return null;
        case AppAuthStatus.unauthenticated:
          if (isOnAuthRoute) {
            return null;
          }
          return AppRoutes.signIn;
        case AppAuthStatus.awaitingEmailConfirmation:
          if (location == AppRoutes.confirmEmail) {
            return null;
          }
          return AppRoutes.confirmEmail;
        case AppAuthStatus.needsWorkspace:
          if (isWorkspaceSetup) {
            return null;
          }
          return AppRoutes.workspaceSetup;
        case AppAuthStatus.authenticated:
          if (isOnAuthRoute || isWorkspaceSetup) {
            return AppRoutes.home;
          }
          return null;
      }
    },
    routes: [
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpScreen()),
      GoRoute(
          path: AppRoutes.magicLink,
          builder: (_, __) => const MagicLinkScreen()),
      GoRoute(
          path: AppRoutes.confirmEmail,
          builder: (_, __) => const ConfirmEmailScreen()),
      GoRoute(
          path: AppRoutes.workspaceSetup,
          builder: (_, __) => const WorkspaceSetupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.leads,
                builder: (_, state) {
                  final initialStatus = state.uri.queryParameters['status'];
                  return LeadsScreen(initialStatus: initialStatus);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.jobs,
                builder: (_, __) => const JobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
          path: AppRoutes.leadCapture,
          builder: (_, __) => const LeadCaptureScreen()),
      GoRoute(
        path: AppRoutes.leadDetail,
        builder: (_, state) =>
            LeadDetailScreen(leadId: state.pathParameters['leadId']),
      ),
      GoRoute(
        path: AppRoutes.jobDetail,
        builder: (_, state) =>
            JobDetailScreen(jobId: state.pathParameters['jobId']),
      ),
      GoRoute(
          path: AppRoutes.clients, builder: (_, __) => const ClientsScreen()),
      GoRoute(
        path: AppRoutes.clientCreate,
        builder: (_, __) => const ClientDetailScreen(isCreateFlow: true),
      ),
      GoRoute(
        path: AppRoutes.clientDetail,
        builder: (_, state) =>
            ClientDetailScreen(clientId: state.pathParameters['clientId']),
      ),
      GoRoute(
        path: AppRoutes.projectCreate,
        builder: (_, __) => const ProjectCreationScreen(),
      ),
      GoRoute(
        path: AppRoutes.dailySweepReview,
        builder: (_, __) => const DailySweepScreen(),
      ),
      GoRoute(
          path: AppRoutes.followups,
          builder: (_, __) => const FollowupsScreen()),
      GoRoute(
        path: AppRoutes.followupSettings,
        builder: (_, __) => const FollowupSettingsScreen(),
      ),
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const DataImportScreen()),
    ],
  );
});

class _AppShell extends StatefulWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Leads',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
