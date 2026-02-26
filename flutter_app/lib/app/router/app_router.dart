import 'package:go_router/go_router.dart';

import '../../features/auth/magic_link_screen.dart';
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

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpScreen()),
      GoRoute(path: AppRoutes.magicLink, builder: (_, __) => const MagicLinkScreen()),
      GoRoute(path: AppRoutes.workspaceSetup, builder: (_, __) => const WorkspaceSetupScreen()),
      GoRoute(path: AppRoutes.leads, builder: (_, __) => const LeadsScreen()),
      GoRoute(path: AppRoutes.leadCapture, builder: (_, __) => const LeadCaptureScreen()),
      GoRoute(
        path: AppRoutes.leadDetail,
        builder: (_, state) => LeadDetailScreen(leadId: state.pathParameters['leadId']),
      ),
      GoRoute(path: AppRoutes.jobs, builder: (_, __) => const JobsScreen()),
      GoRoute(
        path: AppRoutes.jobDetail,
        builder: (_, state) => JobDetailScreen(jobId: state.pathParameters['jobId']),
      ),
      GoRoute(path: AppRoutes.clients, builder: (_, __) => const ClientsScreen()),
      GoRoute(
        path: AppRoutes.clientCreate,
        builder: (_, __) => const ClientDetailScreen(isCreateFlow: true),
      ),
      GoRoute(
        path: AppRoutes.clientDetail,
        builder: (_, state) => ClientDetailScreen(clientId: state.pathParameters['clientId']),
      ),
      GoRoute(
        path: AppRoutes.projectCreate,
        builder: (_, __) => const ProjectCreationScreen(),
      ),
      GoRoute(
        path: AppRoutes.dailySweepReview,
        builder: (_, __) => const DailySweepScreen(),
      ),
      GoRoute(path: AppRoutes.followups, builder: (_, __) => const FollowupsScreen()),
      GoRoute(
        path: AppRoutes.followupSettings,
        builder: (_, __) => const FollowupSettingsScreen(),
      ),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const DataImportScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
    ],
  );
}
