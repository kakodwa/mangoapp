// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/app_colors.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart'; // Ensure you import your new reset screen here

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _logoErrorShown = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String formatError(dynamic error) {
    final msg = error.toString();
    if (msg.contains('401')) {
      return 'Incorrect username or password.';
    }
    if (msg.contains('400')) {
      return 'Invalid request. Please check your input.';
    }
    if (msg.contains('500')) {
      return 'Server error. Please try again later.';
    }
    if (msg.contains('SocketException') || msg.contains('network')) {
      return 'No internet connection.';
    }
    return 'Login failed. Please try again.';
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    try {
      final authNotifier = ref.read(authProvider.notifier);

      await authNotifier.login(
        username: username,
        password: password,
      );

      final authState = ref.read(authProvider);

      if (authState.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError(
          authState.error ?? 'Login failed. Please try again',
        );
      }
    } catch (e) {
      _showError(formatError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktopOrTablet = constraints.maxWidth > 600;
                
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktopOrTablet ? AppSpacing.xl : AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
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
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo Wrapper
                            Center(
                              child: Image.asset(
                                'assets/images/logo2.png',
                                height: 90,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  if (!_logoErrorShown) {
                                    _logoErrorShown = true;
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _showError('Logo failed to load');
                                    });
                                  }
                                  return const Icon(
                                    Icons.storefront_rounded, 
                                    size: 70, 
                                    color: AppColors.mangoOrange,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Welcoming Context Headings
                            Text(
                              'Welcome Back',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkText,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Log in to continue secure marketplace trading',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Input Text Fields Framework
                            AppTextField(
                              label: 'Username',
                              hint: 'Enter your username',
                              controller: _usernameController,
                              prefix: const Icon(Icons.person_outline, color: Colors.grey),
                              isRequired: true,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              type: TextFieldType.password,
                              prefix: const Icon(Icons.lock_outline, color: Colors.grey),
                              isRequired: true,
                            ),
                            
                            // 🌟 Beautiful Forgot Password Redirection Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.mangoOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Primary Action Button Pipeline
                            AppButton(
                              text: authState.isLoading ? 'Logging in...' : 'Sign In',
                              onPressed: authState.isLoading ? null : _handleLogin,
                              loading: authState.isLoading,
                              fullWidth: true,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Footer Redirection Layout
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: AppColors.mangoOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}