import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';
import 'providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;
  String? _errorMessage;

  String? _validateFullName() {
    if (_fullNameController.text.trim().isEmpty) {
      return 'Full name is required';
    }

    return null;
  }

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

    if (password.length < 8) {
      return 'Use at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text.trim();
    if (confirmPassword.isEmpty) {
      return 'Confirm your password';
    }

    if (confirmPassword != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  bool get _isFormValid =>
      _validateFullName() == null &&
      _validateEmail() == null &&
      _validatePassword() == null &&
      _validateConfirmPassword() == null;

  bool get _showEmptyState =>
      _fullNameController.text.trim().isEmpty && _emailController.text.trim().isEmpty;

  Future<void> _handleCreateAccountPressed() async {
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
      await ref.read(authProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          );

      if (!mounted) {
        return;
      }
      context.go(AppRoutes.workspaceSetup);
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error, stackTrace) {
      debugPrint('Sign up failed: $error');
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    return raw.isNotEmpty ? raw : 'Could not create account. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create your account', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Set up login credentials now, then create your workspace next.',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _FormContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isLoading,
                      onChanged: (_) => setState(() {
                        _errorMessage = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        hintText: 'Michael Rodriguez',
                        errorText: _submitted ? _validateFullName() : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      onChanged: (_) => setState(() {
                        _errorMessage = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Work email',
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      enabled: !_isLoading,
                      onChanged: (_) => setState(() {
                        _errorMessage = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        hintText: 'Re-enter password',
                        errorText: _submitted ? _validateConfirmPassword() : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleCreateAccountPressed,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.push(AppRoutes.magicLink),
                        child: const Text('Use Magic Link Instead'),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go(AppRoutes.signIn),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusCard(
                  title: 'Sign up failed',
                  body: _errorMessage!,
                  icon: Icons.error_outline,
                ),
              ],
              if (_showEmptyState) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'No workspace profile yet',
                  body: 'Your business workspace is created in the next onboarding step.',
                  icon: Icons.storefront_outlined,
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
