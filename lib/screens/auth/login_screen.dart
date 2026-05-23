import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/app_colors.dart';
import 'register_screen.dart';

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
      SnackBar(content: Text(message)),
    );
  }

  /// ✅ CLEAN ERROR FORMATTER (IMPORTANT)
  String formatError(dynamic error) {
    final msg = error.toString();

    if (msg.contains('401')) {
      return 'Login failed:\nIncorrect username or password';
    }
    if (msg.contains('400')) {
      return 'Invalid request.\nPlease check your input';
    }
    if (msg.contains('500')) {
      return 'Server error.\nPlease try again later';
    }
    if (msg.contains('SocketException') || msg.contains('network')) {
      return 'No internet connection';
    }

    return 'Login failed.\nPlease try again';
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
      _showError(formatError(e)); // ✅ CLEAN 1–2 LINE ERROR
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ✅ LOGO (UNCHANGED)
              Image.asset(
                'assets/images/logo2.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  if (!_logoErrorShown) {
                    _logoErrorShown = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showError('Logo failed to load');
                    });
                  }
                  return Icon(Icons.broken_image, size: 80);
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Log in to your account to continue shopping',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: AppSpacing.xl),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Username',
                      hint: 'Enter your username',
                      controller: _usernameController,
                      prefix: Icon(Icons.person),
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      type: TextFieldType.password,
                      prefix: Icon(Icons.lock),
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: authState.isLoading ? 'Logging in...' : 'Login',
                        onPressed: authState.isLoading ? null : _handleLogin,
                        loading: authState.isLoading,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
    );
  }
}
