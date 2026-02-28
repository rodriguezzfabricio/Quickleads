import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import 'providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitted = false;
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

  String? _validatePassword() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  bool get _isFormValid => _validateEmail() == null && _validatePassword() == null;

  bool get _showEmptyState =>
      _emailController.text.trim().isEmpty && _passwordController.text.trim().isEmpty;

  Future<void> _handleSignInPressed() async {
    setState(() {
      _submitted = true;
    });

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Router redirect handles navigation based on authProvider state:
      //   authenticated   → home
      //   needsWorkspace  → workspace-setup
      if (!mounted) {
        return;
      }
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
        _errorMessage = 'Sign in failed. Please verify your email and password.';
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Sign in with your email and password to open your workspace.',
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
                      onChanged: (_) => setState(() {
                        _errorMessage = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'owner@contractor.com',
                        errorText: _submitted ? _validateEmail() : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !_isLoading,
                      onChanged: (_) => setState(() {
                        _errorMessage = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'At least 8 characters',
                        errorText: _submitted ? _validatePassword() : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleSignInPressed,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.push(AppRoutes.magicLink),
                        child: const Text('Use Magic Link'),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.push(AppRoutes.signUp),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusCard(
                  title: 'Sign in failed',
                  body: _errorMessage!,
                  icon: Icons.error_outline,
                ),
              ],
              if (_showEmptyState) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'No account details entered yet',
                  body: 'Add email and password to unlock the sign-in action.',
                  icon: Icons.info_outline,
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
