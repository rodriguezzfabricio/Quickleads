import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';

class MagicLinkScreen extends StatefulWidget {
  const MagicLinkScreen({super.key});

  @override
  State<MagicLinkScreen> createState() => _MagicLinkScreenState();
}

class _MagicLinkScreenState extends State<MagicLinkScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _submitted = false;
  bool _linkSent = false;

  String? _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email';
    }

    return null;
  }

  bool get _isEmailValid => _validateEmail() == null;

  void _handleSendPressed() {
    setState(() {
      _submitted = true;
      _linkSent = _isEmailValid;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = _emailController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Magic link')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Password-free sign in', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Send a secure sign-in link to your email. This is a fallback login path.',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _FormContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        setState(() {
                          _linkSent = false;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'owner@contractor.com',
                        errorText: _submitted ? _validateEmail() : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _handleSendPressed,
                        child: Text(_linkSent ? 'Resend Magic Link' : 'Send Magic Link'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.signIn),
                        child: const Text('Back to Sign In'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.signUp),
                      child: const Text('Need an account? Sign Up'),
                    ),
                  ],
                ),
              ),
              if (!_linkSent && email.isEmpty) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'No email entered yet',
                  body: 'Add your account email to preview the magic-link send state.',
                  icon: Icons.mail_outline,
                ),
              ],
              if (_linkSent) ...[
                const SizedBox(height: 16),
                _StatusCard(
                  title: 'Magic link sent',
                  body: 'A sign-in link will be sent to $email once backend integration is connected.',
                  icon: Icons.check_circle_outline,
                  iconColor: AppTokens.success,
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
    this.iconColor = Colors.white70,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;

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
            Icon(icon, color: iconColor),
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
