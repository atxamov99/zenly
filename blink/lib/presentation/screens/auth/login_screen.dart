import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = await ref.read(signInEmailUseCaseProvider).call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      await ref.read(authStateProvider.notifier).setAuthenticated(uid);
      if (!mounted) return;
      final exists = await ref.read(userProfileExistsProvider.future);
      if (!mounted) return;
      context.go(exists ? AppRoutes.home : AppRoutes.profileSetup);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uid = await ref.read(signInGoogleUseCaseProvider).call();
      await ref.read(authStateProvider.notifier).setAuthenticated(uid);
      if (!mounted) return;
      final exists = await ref.read(userProfileExistsProvider.future);
      if (!mounted) return;
      context.go(exists ? AppRoutes.home : AppRoutes.profileSetup);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),
                const Text(
                  'Welcome to\nBlink 👋',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Sign in with your email',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xl),
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
                  label: 'Sign In',
                  onPressed: _signInEmail,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSizes.md),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    child: Text('or', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: AppSizes.md),
                AppButton(
                  label: AppStrings.continueWithGoogle,
                  onPressed: _signInGoogle,
                  isOutlined: true,
                  leading: const Icon(Icons.g_mobiledata, size: 22),
                ),
                const SizedBox(height: AppSizes.sm),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Create a new account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
