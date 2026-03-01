import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/providers.dart';
import '../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _businessNameController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _savingInfo = false;
  bool _loggingOut = false;
  String? _logoutError;
  String? _boundOrgId;
  String? _boundProfileId;
  ProviderSubscription<AsyncValue<LocalOrganization?>>? _orgSubscription;
  ProviderSubscription<AsyncValue<LocalProfile?>>? _profileSubscription;
  LocalOrganization? _latestOrganization;
  LocalProfile? _latestProfile;

  /// Track whether we've pre-populated the text fields from the DB.
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
            content: Text('Business name and contractor name are required.')),
      );
      return;
    }

    setState(() => _savingInfo = true);

    final orgsDao = ref.read(organizationsDaoProvider);

    try {
      // Always persist locally first (works offline).
      await orgsDao.updateOrganizationName(orgId, orgName);
      await orgsDao.updateProfileName(profileId, contractorName);
      await orgsDao.updateProfilePhone(profileId, phone);

      // Attempt cloud sync if online. Local persistence already succeeded.
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
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

  void _bindHydrationListeners({
    required String orgId,
    required String profileId,
  }) {
    if (_boundOrgId == orgId && _boundProfileId == profileId) {
      return;
    }

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
    if (organization == null || profile == null) {
      return;
    }
    _populate(
      businessName: organization.name,
      contractorName: profile.fullName,
      phone: profile.phoneE164,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authAsync = ref.watch(authProvider);
    final orgId = authAsync.valueOrNull?.profile?.organizationId ?? '';
    final profileId = authAsync.valueOrNull?.profile?.id ?? '';

    if (orgId.isNotEmpty && profileId.isNotEmpty) {
      _bindHydrationListeners(orgId: orgId, profileId: profileId);
      ref.watch(organizationProvider(orgId));
      ref.watch(profileProvider(profileId));
    } else if (_boundOrgId != null || _boundProfileId != null) {
      _orgSubscription?.close();
      _profileSubscription?.close();
      _orgSubscription = null;
      _profileSubscription = null;
      _boundOrgId = null;
      _boundProfileId = null;
      _latestOrganization = null;
      _latestProfile = null;
      _populated = false;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Business Info ─────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business_outlined,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Business Info',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storefront_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contractorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Contractor Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+1 555 000 0000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed:
                            _savingInfo || orgId.isEmpty || profileId.isEmpty
                                ? null
                                : () => _saveBusinessInfo(orgId, profileId),
                        child: _savingInfo
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Business Info'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── App Links ─────────────────────────────────────────────
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.message_outlined),
                    title: const Text('Follow-Up Settings'),
                    subtitle:
                        const Text('Edit Day 2, 5, and 10 message templates'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.followupSettings),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.upload_file_outlined),
                    title: const Text('Data Import'),
                    subtitle: const Text('Import contacts from CSV'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.onboarding),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Account ───────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Account',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _loggingOut ? null : _handleLogout,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.danger,
                        ),
                        child: _loggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Log Out'),
                      ),
                    ),
                    if (_logoutError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _logoutError!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppTokens.danger),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
