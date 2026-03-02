import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/platform/call_permissions.dart';
import '../../core/notifications/notification_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final _permissions = CallPermissions();
  bool _loading = false;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  Future<void> _continueToImport() async {
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.importData);
  }

  Future<void> _handleAllow() async {
    setState(() => _loading = true);

    try {
      if (_isAndroid) {
        await _permissions.requestAndroidCallPermissions();
      }
      await NotificationService.instance.requestPermissions();
      await _permissions.markPromptSeen();
      await _continueToImport();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleSkip() async {
    await _permissions.markPromptSeen();
    await _continueToImport();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Enable key permissions', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(
                _isAndroid
                    ? 'Allow call and notification permissions so CrewCommand can capture unknown calls and remind you to review daily sweeps.'
                    : 'Allow notifications so CrewCommand can remind you to review daily sweeps.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      if (_isAndroid)
                        const ListTile(
                          leading: Icon(Icons.call_outlined),
                          title: Text('Call Access'),
                          subtitle: Text('Detect call activity for unknown-caller capture.'),
                        ),
                      const ListTile(
                        leading: Icon(Icons.notifications_outlined),
                        title: Text('Notifications'),
                        subtitle: Text('Get call detection and daily sweep reminders.'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _loading ? null : _handleAllow,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Allow'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _loading ? null : _handleSkip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
