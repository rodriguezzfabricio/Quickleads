import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

import '../../app/router/app_router.dart';
import '../../core/network/supabase_constants.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../../core/sync/sync_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _businessNameController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _notificationsEnabled = true;
  bool _savingInfo = false;
  bool _runningSync = false;
  bool _loggingOut = false;
  String? _logoutError;

  String? _boundOrgId;
  String? _boundProfileId;
  ProviderSubscription<AsyncValue<LocalOrganization?>>? _orgSubscription;
  ProviderSubscription<AsyncValue<LocalProfile?>>? _profileSubscription;
  LocalOrganization? _latestOrganization;
  LocalProfile? _latestProfile;
  bool _populated = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _contractorNameController.dispose();
    _phoneController.dispose();
    _orgSubscription?.close();
    _profileSubscription?.close();
    super.dispose();
  }

  void _populate({
    required String businessName,
    required String contractorName,
    required String? phone,
  }) {
    if (_populated) return;
    _populated = true;
    _businessNameController.text = businessName;
    _contractorNameController.text = contractorName;
    _phoneController.text = phone ?? '';
  }

  Future<void> _saveBusinessInfo(String orgId, String profileId) async {
    final orgName = _businessNameController.text.trim();
    final contractorName = _contractorNameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty
        ? null
        : _phoneController.text.trim();

    if (orgName.isEmpty || contractorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business name and contractor name are required.'),
        ),
      );
      return;
    }

    setState(() => _savingInfo = true);

    final orgsDao = ref.read(organizationsDaoProvider);

    try {
      await orgsDao.updateOrganizationName(orgId, orgName);
      await orgsDao.updateProfileName(profileId, contractorName);
      await orgsDao.updateProfilePhone(profileId, phone);

      try {
        final client = Supabase.instance.client;
        await Future.wait([
          client
              .from('organizations')
              .update({'name': orgName}).eq('id', orgId),
          client.from('profiles').update({
            'full_name': contractorName,
            'phone_e164': phone,
          }).eq('id', profileId),
        ]);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved and synced.')),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Saved locally. Cloud sync failed; retry once online.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingInfo = false);
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _loggingOut = true;
      _logoutError = null;
    });

    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      context.go(AppRoutes.signIn);
    } catch (_) {
      if (!mounted) return;
      setState(() => _logoutError = 'Could not log out. Please try again.');
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  void _bindHydrationListeners(
      {required String orgId, required String profileId}) {
    if (_boundOrgId == orgId && _boundProfileId == profileId) return;

    _orgSubscription?.close();
    _profileSubscription?.close();
    _boundOrgId = orgId;
    _boundProfileId = profileId;
    _latestOrganization = null;
    _latestProfile = null;
    _populated = false;

    _orgSubscription = ref.listenManual<AsyncValue<LocalOrganization?>>(
      organizationProvider(orgId),
      (_, next) {
        _latestOrganization = next.valueOrNull;
        _tryPopulateFromLatest();
      },
      fireImmediately: true,
    );

    _profileSubscription = ref.listenManual<AsyncValue<LocalProfile?>>(
      profileProvider(profileId),
      (_, next) {
        _latestProfile = next.valueOrNull;
        _tryPopulateFromLatest();
      },
      fireImmediately: true,
    );
  }

  void _tryPopulateFromLatest() {
    final organization = _latestOrganization;
    final profile = _latestProfile;
    if (organization == null || profile == null) return;
    _populate(
      businessName: organization.name,
      contractorName: profile.fullName,
      phone: profile.phoneE164,
    );
  }

  String _projectRefFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    final parts = host.split('.');
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'unknown';
    }
    return parts.first;
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '—';
    }
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }

  Future<void> _runSyncNow() async {
    if (_runningSync) {
      return;
    }

    setState(() => _runningSync = true);
    final result = await ref.read(syncEngineProvider).syncNow();
    if (!mounted) {
      return;
    }

    setState(() => _runningSync = false);
    final text = result.hasErrors
        ? 'Sync completed with errors. ${result.errorMessage ?? ''}'.trim()
        : 'Sync completed. Pulled ${result.pulledCount}, pushed ${result.pushedCount}.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _buildSyncDiagnosticsReport({
    required SyncDiagnostics diagnostics,
    required String projectRef,
    required String projectUrl,
    required String userId,
    required String orgId,
    required String? deviceId,
  }) {
    return [
      'CrewCommand Sync Diagnostics',
      'Project Ref: $projectRef',
      'Project URL: $projectUrl',
      'Auth User ID: ${userId.isEmpty ? '—' : userId}',
      'Org ID: ${orgId.isEmpty ? '—' : orgId}',
      'Device ID: ${deviceId == null || deviceId.isEmpty ? '—' : deviceId}',
      'Current Status: ${diagnostics.currentStatus.name}',
      'Last Attempt: ${_formatDateTime(diagnostics.lastAttemptAt)}',
      'Last Success: ${_formatDateTime(diagnostics.lastSuccessAt)}',
      'Last Completed: ${_formatDateTime(diagnostics.lastCompletedAt)}',
      'Last Push Count: ${diagnostics.lastPushedCount}',
      'Last Pull Count: ${diagnostics.lastPulledCount}',
      'Last Conflict Count: ${diagnostics.lastConflictCount}',
      'Last Error Code: ${diagnostics.lastErrorCode ?? '—'}',
      'Last Error: ${diagnostics.lastErrorMessage ?? '—'}',
      'Push Error Code: ${diagnostics.lastPushErrorCode ?? '—'}',
      'Push Error: ${diagnostics.lastPushErrorMessage ?? '—'}',
      'Pull Error Code: ${diagnostics.lastPullErrorCode ?? '—'}',
      'Pull Error: ${diagnostics.lastPullErrorMessage ?? '—'}',
    ].join('\n');
  }

  Future<void> _copySyncDiagnostics({
    required SyncDiagnostics diagnostics,
    required String projectRef,
    required String projectUrl,
    required String userId,
    required String orgId,
    required String? deviceId,
  }) async {
    final report = _buildSyncDiagnosticsReport(
      diagnostics: diagnostics,
      projectRef: projectRef,
      projectUrl: projectUrl,
      userId: userId,
      orgId: orgId,
      deviceId: deviceId,
    );
    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync diagnostics copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final syncDiagnosticsAsync = ref.watch(syncDiagnosticsProvider);
    final deviceIdAsync = ref.watch(registeredServerDeviceIdProvider);
    final syncDiagnostics =
        syncDiagnosticsAsync.valueOrNull ?? const SyncDiagnostics();
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';
    final profileId = authAsync.valueOrNull?.profile?.id ?? '';
    final authUserId = authAsync.valueOrNull?.user?.id ?? '';
    final deviceId = deviceIdAsync.valueOrNull;
    const projectUrl = SupabaseConstants.url;
    final projectRef = _projectRefFromUrl(projectUrl);

    if (orgId.isNotEmpty && profileId.isNotEmpty) {
      _bindHydrationListeners(orgId: orgId, profileId: profileId);
      ref.watch(organizationProvider(orgId));
      ref.watch(profileProvider(profileId));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.foreground, size: 24),
                ),
                const SizedBox(width: 2),
                Text('Settings', style: AppTextStyles.h1),
              ],
            ),
            const SizedBox(height: 12),
            Text('BUSINESS', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _EditableRow(
                    label: 'Business Name',
                    controller: _businessNameController,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _EditableRow(
                    label: 'Your Name',
                    controller: _contractorNameController,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _EditableRow(
                    label: 'Phone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _savingInfo || orgId.isEmpty || profileId.isEmpty
                  ? null
                  : () => _saveBusinessInfo(orgId, profileId),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _savingInfo
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Business Info'),
            ),
            const SizedBox(height: 16),
            Text('FOLLOW-UP', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.push(AppRoutes.followupSettings),
              child: GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.settings,
                        color: AppColors.mutedFg, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Follow-up Sequence',
                        style: AppTextStyles.h3.copyWith(fontSize: 17),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.mutedFg, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('PREFERENCES', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.notifications_none,
                      color: AppColors.mutedFg, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: AppTextStyles.h3.copyWith(fontSize: 17),
                        ),
                        Text(
                          'Reminders & updates',
                          style: AppTextStyles.tiny.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _IosToggle(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('SYNC DIAGNOSTICS', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DiagnosticsRow(
                    label: 'Project Ref',
                    value: projectRef,
                  ),
                  _DiagnosticsRow(
                    label: 'Project URL',
                    value: projectUrl,
                  ),
                  _DiagnosticsRow(
                    label: 'Auth User ID',
                    value: authUserId.isEmpty ? '—' : authUserId,
                  ),
                  _DiagnosticsRow(
                    label: 'Org ID',
                    value: orgId.isEmpty ? '—' : orgId,
                  ),
                  _DiagnosticsRow(
                    label: 'Device ID',
                    value:
                        (deviceId == null || deviceId.isEmpty) ? '—' : deviceId,
                  ),
                  _DiagnosticsRow(
                    label: 'Current Status',
                    value: syncDiagnostics.currentStatus.name,
                  ),
                  _DiagnosticsRow(
                    label: 'Last Attempt',
                    value: _formatDateTime(syncDiagnostics.lastAttemptAt),
                  ),
                  _DiagnosticsRow(
                    label: 'Last Success',
                    value: _formatDateTime(syncDiagnostics.lastSuccessAt),
                  ),
                  _DiagnosticsRow(
                    label: 'Last Error Code',
                    value: syncDiagnostics.lastErrorCode ?? '—',
                  ),
                  _DiagnosticsRow(
                    label: 'Last Error',
                    value: syncDiagnostics.lastErrorMessage ?? '—',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _runningSync ? null : _runSyncNow,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _runningSync
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Run Sync Now'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _copySyncDiagnostics(
                            diagnostics: syncDiagnostics,
                            projectRef: projectRef,
                            projectUrl: projectUrl,
                            userId: authUserId,
                            orgId: orgId,
                            deviceId: deviceId,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side:
                                const BorderSide(color: AppColors.glassBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Copy',
                            style: AppTextStyles.h4.copyWith(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reset workflow: Sign out, delete simulator app data, sign in again, verify sync_cursors has "all", then confirm clients load.',
              style: AppTextStyles.tiny.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text('ACCOUNT', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_outlined,
                            color: AppColors.mutedFg, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Subscription & Billing',
                            style: AppTextStyles.h3.copyWith(fontSize: 17),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.mutedFg, size: 18),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  TextButton(
                    onPressed: _loggingOut ? null : _handleLogout,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout,
                            color: AppColors.systemRed, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _loggingOut ? 'Logging out...' : 'Log Out',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 17,
                            color: AppColors.systemRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_logoutError != null) ...[
              const SizedBox(height: 8),
              Text(
                _logoutError!,
                style: AppTextStyles.tiny.copyWith(color: AppColors.systemRed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.tiny.copyWith(fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: AppTextStyles.secondary.copyWith(
                fontSize: 15,
                color: AppColors.foreground,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsRow extends StatelessWidget {
  const _DiagnosticsRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: AppTextStyles.tiny.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.secondary.copyWith(
                fontSize: 13,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IosToggle extends StatelessWidget {
  const _IosToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          color: value ? AppColors.systemGreen : const Color(0x52787880),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
