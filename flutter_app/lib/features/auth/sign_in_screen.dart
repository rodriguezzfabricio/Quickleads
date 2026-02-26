import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../core/constants/app_tokens.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitted = false;

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

  void _handleSignInPressed() {
    setState(() {
      _submitted = true;
    });
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
                      onChanged: (_) => setState(() {}),
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
                      onChanged: (_) => setState(() {}),
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
                        onPressed: _handleSignInPressed,
                        child: const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.push(AppRoutes.magicLink),
                        child: const Text('Use Magic Link'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.signUp),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ),
              if (_showEmptyState) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'No account details entered yet',
                  body: 'Add email and password to unlock the sign-in action.',
                  icon: Icons.info_outline,
                ),
              ],
              if (_submitted && _isFormValid) ...[
                const SizedBox(height: 16),
                const _StatusCard(
                  title: 'Validation passed',
                  body: 'Auth backend wiring is intentionally deferred for integration.',
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
