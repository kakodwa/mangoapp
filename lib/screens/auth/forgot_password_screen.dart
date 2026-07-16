// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/app_colors.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.redAccent : AppColors.leafGreen,
      ),
    );
  }

  // Phase 1: Request Reset Token from Django Backend
  Future<void> _handleSendResetCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showNotification('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiClient.requestPasswordReset(email);
      _showNotification('Verification code sent to your email!', isError: false);
      setState(() {
        _isCodeSent = true;
      });
    } catch (e) {
      _showNotification(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Phase 2: Post OTP & New Password back to Django's /confirm/ endpoint
  Future<void> _handleConfirmReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiClient.confirmPasswordReset(
        otpCode: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      _showNotification('Password changed successfully! Please log in.', isError: false);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Formats and displays Django API exception validation messages cleanly
      _showNotification(e.toString().replaceAll('ApiException:', '').trim());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTabletOrWeb = screenWidth > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.mangoOrange,
              Color(0xFFFF8C00),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isTabletOrWeb ? 40.0 : 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Center(
                          child: Icon(
                            _isCodeSent ? Icons.mark_email_read_outlined : Icons.lock_reset_outlined,
                            size: 70,
                            color: AppColors.mangoOrange,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          _isCodeSent ? 'New Credentials' : 'Reset Password',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _isCodeSent
                              ? 'Enter the recovery OTP sent to your mailbox along with your new password choice.'
                              : 'Enter your email address below to receive an account verification code.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        if (!_isCodeSent) ...[
                          AppTextField(
                            label: 'Email Address',
                            hint: 'Enter your registered email',
                            controller: _emailController,
                            type: TextFieldType.email,
                            prefix: const Icon(Icons.mail_outline, color: Colors.grey),
                            isRequired: true,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            text: _isLoading ? 'Generating OTP...' : 'Send OTP Code',
                            onPressed: _isLoading ? null : _handleSendResetCode,
                            loading: _isLoading,
                            fullWidth: true,
                          ),
                        ] else ...[
                          AppTextField(
                            label: '6-Digit Verification Code',
                            hint: 'Enter OTP Code',
                            controller: _otpController,
                            prefix: const Icon(Icons.vpn_key_outlined, color: Colors.grey),
                            isRequired: true,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'New Password',
                            hint: 'At least 6 characters',
                            controller: _newPasswordController,
                            type: TextFieldType.password,
                            prefix: const Icon(Icons.lock_outline, color: Colors.grey),
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Confirm New Password',
                            hint: 'Re-type new password',
                            controller: _confirmPasswordController,
                            type: TextFieldType.password,
                            prefix: const Icon(Icons.lock_outline, color: Colors.grey),
                            isRequired: true,
                            validator: (value) {
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            text: _isLoading ? 'Resetting Password...' : 'Verify & Reset',
                            onPressed: _isLoading ? null : _handleConfirmReset,
                            loading: _isLoading,
                            fullWidth: true,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => setState(() => _isCodeSent = false),
                            child: const Text(
                              "Change recovery email",
                              style: TextStyle(color: AppColors.mangoOrange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}