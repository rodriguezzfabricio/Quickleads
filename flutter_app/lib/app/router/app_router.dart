import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';
import '../../core/storage/providers.dart';
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
                path: AppRoutes.clients,
                builder: (_, __) => const ClientsScreen(),
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
        ],
      ),
      GoRoute(
        path: AppRoutes.leadCapture,
        builder: (_, state) => LeadCaptureScreen(
          initialPhone: state.uri.queryParameters['phone'],
        ),
      ),
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
        path: AppRoutes.clientCreate,
        builder: (_, state) => ClientDetailScreen(
          isCreateFlow: true,
          prefillName: state.uri.queryParameters['name'],
          prefillPhone: state.uri.queryParameters['phone'],
        ),
      ),
      GoRoute(
        path: AppRoutes.clientDetail,
        builder: (_, state) =>
            ClientDetailScreen(clientId: state.pathParameters['clientId']),
      ),
      GoRoute(
        path: AppRoutes.projectCreate,
        builder: (_, state) => ProjectCreationScreen(
          prefilledLeadId: state.uri.queryParameters['leadId'],
          prefillName: state.uri.queryParameters['name'],
          prefillPhone: state.uri.queryParameters['phone'],
          prefillJobType: state.uri.queryParameters['jobType'],
        ),
      ),
      GoRoute(
        path: AppRoutes.dailySweepReview,
        builder: (_, state) => DailySweepScreen(
          forcedPlatform: state.uri.queryParameters['platform'],
        ),
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
      GoRoute(
          path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
    ],
  );
});

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  Future<void> _openCreateSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141417),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CreateActionButton(
                    label: '+ New Lead',
                    icon: Icons.phone_outlined,
                    tint: AppTokens.primary,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push(AppRoutes.leadCapture);
                    },
                  ),
                  const SizedBox(height: 10),
                  _CreateActionButton(
                    label: '+ New Project',
                    icon: Icons.assignment_outlined,
                    tint: AppTokens.success,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push(AppRoutes.projectCreate);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(authProvider).valueOrNull?.profile?.organizationId;
    if (orgId != null && orgId.isNotEmpty) {
      ref.watch(debugMockDataSeedProvider(orgId));
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _ShellBottomNav(
        selectedIndex: widget.navigationShell.currentIndex,
        onSelectIndex: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        onCreatePressed: _openCreateSheet,
      ),
    );
  }
}

class _ShellBottomNav extends StatelessWidget {
  const _ShellBottomNav({
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.onCreatePressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ShellNavItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        label: 'Home',
                        selected: selectedIndex == 0,
                        onTap: () => onSelectIndex(0),
                      ),
                    ),
                    Expanded(
                      child: _ShellNavItem(
                        icon: Icons.groups_outlined,
                        selectedIcon: Icons.groups,
                        label: 'Leads',
                        selected: selectedIndex == 1,
                        onTap: () => onSelectIndex(1),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: GestureDetector(
                    onTap: onCreatePressed,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppTokens.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0A0A0A),
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 122, 255, 0.4),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ShellNavItem(
                        icon: Icons.account_circle_outlined,
                        selectedIcon: Icons.account_circle,
                        label: 'Clients',
                        selected: selectedIndex == 2,
                        onTap: () => onSelectIndex(2),
                      ),
                    ),
                    Expanded(
                      child: _ShellNavItem(
                        icon: Icons.work_outline,
                        selectedIcon: Icons.work,
                        label: 'Jobs',
                        selected: selectedIndex == 3,
                        onTap: () => onSelectIndex(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint =
        selected ? AppTokens.primary : Colors.white.withValues(alpha: 0.35);
    final iconData = selected ? selectedIcon : icon;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 23, color: tint),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: tint,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateActionButton extends StatelessWidget {
  const _CreateActionButton({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tint.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: tint),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
