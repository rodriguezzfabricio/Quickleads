import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import '../auth/providers/auth_provider.dart';

class WorkspaceSetupScreen extends ConsumerStatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  ConsumerState<WorkspaceSetupScreen> createState() => _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends ConsumerState<WorkspaceSetupScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  String _timezone = 'America/New_York';
  bool _submitted = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  static const _timezones = <String>[
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'America/Phoenix',
    'America/Anchorage',
    'Pacific/Honolulu',
  ];

  String? _validateBusinessName() {
    if (_businessNameController.text.trim().isEmpty) {
      return 'Business name is required';
    }

    return null;
  }

  bool get _isFormValid => _validateBusinessName() == null;

  Future<void> _handleContinuePressed() async {
    setState(() {
      _submitted = true;
      _errorMessage = null;
    });

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(authProvider.notifier).bootstrapWorkspace(
            businessName: _businessNameController.text.trim(),
            timezone: _timezone,
          );

      if (!mounted) {
        return;
      }
      context.go(AppRoutes.home);
    } catch (error, stackTrace) {
      debugPrint('Workspace bootstrap failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _readErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  String _readErrorMessage(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      final trimmed = raw.substring('Exception: '.length).trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    if (raw.startsWith('StateError: ')) {
      final trimmed = raw.substring('StateError: '.length).trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return raw.isNotEmpty ? raw : 'Could not create workspace. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Workspace setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set up your workspace', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Create your business workspace so your account is linked to an organization.',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _FormContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _businessNameController,
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isSubmitting,
                      onChanged: (_) => setState(() {
                        _errorMessage = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Business name',
                        hintText: 'Rodriguez Contracting',
                        errorText: _submitted ? _validateBusinessName() : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _timezone,
                      items: _timezones
                          .map((timezone) => DropdownMenuItem<String>(
                                value: timezone,
                                child: Text(timezone),
                              ))
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Timezone'),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _timezone = value;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _handleContinuePressed,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Workspace'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                await ref.read(authProvider.notifier).signOut();
                                if (!context.mounted) {
                                  return;
                                }
                                context.go(AppRoutes.signIn);
                              },
                        child: const Text('Cancel and Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusCard(
                  title: 'Workspace setup failed',
                  body: _errorMessage!,
                  icon: Icons.error_outline,
                ),
              ],
              if (_submitted && _isFormValid && _errorMessage == null && !_isSubmitting) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'Ready to create workspace',
                  body: 'Submit to call auth-bootstrap and finish onboarding.',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FormContainer extends StatelessWidget {
  const _FormContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.glass,
        border: Border.all(color: AppTokens.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.glassElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(body, style: textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
