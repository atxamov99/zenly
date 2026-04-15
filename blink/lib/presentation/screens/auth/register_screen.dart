import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = await ref.read(registerEmailUseCaseProvider).call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
            displayName: _displayNameController.text.trim(),
          );
      await ref.read(authStateProvider.notifier).setAuthenticated(uid);
      if (!mounted) return;
      final profileExists = await ref.read(userProfileExistsProvider.future);
      if (!mounted) return;
      context.go(profileExists ? AppRoutes.home : AppRoutes.profileSetup);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.lg),
              AppTextField(
                hint: 'Display name',
                controller: _displayNameController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                hint: 'Username (e.g. abdulaziz)',
                controller: _usernameController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 3) return 'At least 3 characters';
                  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v)) {
                    return 'Lowercase letters, numbers, underscores only';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                hint: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                hint: 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: AppSizes.md),
              AppButton(
                label: 'Create Account',
                onPressed: _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
