import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/platform/call_detector_android.dart';
import '../../core/platform/call_detector_ios.dart';
import '../../core/constants/app_runtime_flags.dart';
import '../../core/notifications/notification_service.dart';
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
import '../../features/onboarding/permissions_screen.dart';
import '../../features/onboarding/workspace_setup_screen.dart';
import '../../features/projects/project_creation_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/bottom_nav.dart';

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
  static const permissions = '/onboarding/permissions';
  static const importData = '/import';
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
          prefillLeadId: state.uri.queryParameters['leadId'],
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
          path: AppRoutes.permissions,
          builder: (_, __) => const PermissionsScreen()),
      GoRoute(
          path: AppRoutes.importData,
          builder: (_, __) => const DataImportScreen()),
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
  final _androidCallDetector = CallDetectorAndroid();
  CallDetectorIos? _iosCallDetector;
  StreamSubscription<String>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeOrchestration());
  }

  @override
  void dispose() {
    _androidCallDetector.dispose();
    _iosCallDetector?.dispose();
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeOrchestration() async {
    ref.read(syncEngineProvider);
    await NotificationService.instance.scheduleDailySweepReminder();

    _notificationTapSubscription =
        NotificationService.instance.tapPayloadStream.listen(
      _handleNotificationPayload,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _androidCallDetector.start(ref);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _iosCallDetector = CallDetectorIos(
        onLikelyCallDetected: _showIosCallPrompt,
      )..start();
    }
  }

  Future<void> _showIosCallPrompt() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Were you just on a call?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Save the number as a lead if it was a new client call.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  this.context.push(AppRoutes.leadCapture);
                },
                child: const Text('Yes, enter number'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationPayload(String payload) {
    if (!mounted || !payload.startsWith('route:')) {
      return;
    }
    final route = payload.substring('route:'.length);
    if (route.isNotEmpty) {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(authProvider).valueOrNull?.profile?.organizationId;
    if (AppRuntimeFlags.enableDebugMockSeed &&
        orgId != null &&
        orgId.isNotEmpty) {
      ref.watch(debugMockDataSeedProvider(orgId));
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNav(
        selectedIndex: widget.navigationShell.currentIndex,
        onSelect: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        onCreateLead: () => context.push(AppRoutes.leadCapture),
        onCreateProject: () => context.push(AppRoutes.projectCreate),
      ),
    );
  }
}
