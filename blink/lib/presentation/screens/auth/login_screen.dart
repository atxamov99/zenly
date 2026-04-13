import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verificationId = await ref
          .read(verifyPhoneUseCaseProvider)
          .call(phone.startsWith('+') ? phone : '+$phone');

      if (!mounted) return;
      context.push(AppRoutes.otp, extra: {
        'verificationId': verificationId,
        'phoneNumber': phone,
      });
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
      await ref.read(signInGoogleUseCaseProvider).call();
      // Router handles redirect
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
                'Enter your phone number to get started',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.xl),
              AppTextField(
                hint: '+998 90 123 45 67',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+]'))],
                prefix: const Icon(Icons.phone),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: AppSizes.md),
              AppButton(
                label: 'Send OTP',
                onPressed: _sendOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSizes.md),
              Row(children: const [
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
                  child: Text(AppStrings.orUseEmail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
