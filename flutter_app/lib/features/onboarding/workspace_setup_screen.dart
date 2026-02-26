import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';

class WorkspaceSetupScreen extends StatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  State<WorkspaceSetupScreen> createState() => _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends State<WorkspaceSetupScreen> {
  final TextEditingController _workspaceNameController = TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();
  String? _businessType;
  bool _submitted = false;
  bool _autoFollowupsEnabled = true;

  String? _validateWorkspaceName() {
    if (_workspaceNameController.text.trim().isEmpty) {
      return 'Workspace name is required';
    }

    return null;
  }

  String? _validateBusinessType() {
    if (_businessType == null) {
      return 'Business type is required';
    }

    return null;
  }

  String? _validateInviteEmail() {
    final inviteEmail = _inviteEmailController.text.trim();
    if (inviteEmail.isEmpty) {
      return null;
    }

    if (!inviteEmail.contains('@') || !inviteEmail.contains('.')) {
      return 'Enter a valid teammate email';
    }

    return null;
  }

  bool get _isFormValid =>
      _validateWorkspaceName() == null &&
      _validateBusinessType() == null &&
      _validateInviteEmail() == null;

  void _handleContinuePressed() {
    setState(() {
      _submitted = true;
    });

    if (_isFormValid) {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _workspaceNameController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showInviteEmptyState = _inviteEmailController.text.trim().isEmpty;

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
                'Create your business workspace before importing data and enabling automation.',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _FormContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _workspaceNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Workspace name',
                        hintText: 'Rodriguez Contracting',
                        errorText: _submitted ? _validateWorkspaceName() : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _businessType,
                      items: const [
                        DropdownMenuItem(
                          value: 'General Contractor',
                          child: Text('General Contractor'),
                        ),
                        DropdownMenuItem(
                          value: 'Remodeling',
                          child: Text('Remodeling'),
                        ),
                        DropdownMenuItem(
                          value: 'Handyman',
                          child: Text('Handyman'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _businessType = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Business type',
                        errorText: _submitted ? _validateBusinessType() : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inviteEmailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Invite teammate (optional)',
                        hintText: 'foreman@contractor.com',
                        errorText: _submitted ? _validateInviteEmail() : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _autoFollowupsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _autoFollowupsEnabled = value;
                        });
                      },
                      title: const Text('Enable auto follow-up reminders'),
                      subtitle: const Text('Visual toggle only for Phase 1 UI scaffold'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _handleContinuePressed,
                        child: const Text('Continue to Import'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('Skip for Now'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.signUp),
                      child: const Text('Back to Sign Up'),
                    ),
                  ],
                ),
              ),
              if (showInviteEmptyState) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'No teammate invited yet',
                  body: 'You can continue solo now and invite teammates later in settings.',
                  icon: Icons.group_add_outlined,
                ),
              ],
              if (_submitted && _isFormValid) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'Validation passed',
                  body: 'Workspace setup is ready for backend save and onboarding handoff.',
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
