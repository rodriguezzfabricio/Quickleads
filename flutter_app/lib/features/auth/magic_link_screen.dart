import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import 'providers/auth_provider.dart';

class MagicLinkScreen extends ConsumerStatefulWidget {
  const MagicLinkScreen({super.key});

  @override
  ConsumerState<MagicLinkScreen> createState() => _MagicLinkScreenState();
}

class _MagicLinkScreenState extends ConsumerState<MagicLinkScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _submitted = false;
  bool _linkSent = false;
  bool _isLoading = false;
  String? _errorMessage;

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

  Future<void> _handleSendPressed() async {
    setState(() {
      _submitted = true;
      _errorMessage = null;
      _linkSent = false;
    });

    if (!_isEmailValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signInWithOtp(
            email: _emailController.text.trim(),
          );

      if (!mounted) {
        return;
      }
      setState(() {
        _linkSent = true;
      });
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Could not send magic link. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      enabled: !_isLoading,
                      onChanged: (_) {
                        setState(() {
                          _linkSent = false;
                          _errorMessage = null;
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
                        onPressed: _isLoading ? null : _handleSendPressed,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_linkSent ? 'Resend Magic Link' : 'Send Magic Link'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.go(AppRoutes.signIn),
                        child: const Text('Back to Sign In'),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.push(AppRoutes.signUp),
                      child: const Text('Need an account? Sign Up'),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusCard(
                  title: 'Failed to send magic link',
                  body: _errorMessage!,
                  icon: Icons.error_outline,
                ),
              ],
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
                  body: 'A secure sign-in link was sent to $email.',
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
