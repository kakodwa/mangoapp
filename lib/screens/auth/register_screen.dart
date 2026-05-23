import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedUserType = 'customer';

  bool _loading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password != confirm) {
      _showError("Passwords do not match");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = ref.read(authProvider.notifier);

      await auth.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: password,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        userType: _selectedUserType,
      );

      final state = ref.read(authProvider);

      if (state.isAuthenticated) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        _showError(state.error ?? "Registration failed");
      }
    } catch (e) {
      _showError(e.toString());
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                label: "Username",
                controller: _usernameController,
                isRequired: true,
                prefix: const Icon(Icons.person),
              ),

              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                label: "Email",
                controller: _emailController,
                type: TextFieldType.email,
                isRequired: true,
                prefix: const Icon(Icons.email),
              ),

              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                label: "First Name",
                controller: _firstNameController,
                isRequired: true,
                prefix: const Icon(Icons.person_outline),
              ),

              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                label: "Last Name",
                controller: _lastNameController,
                isRequired: true,
                prefix: const Icon(Icons.person_outline),
              ),

              const SizedBox(height: AppSpacing.sm),

              DropdownButtonFormField<String>(
                value: _selectedUserType,
                decoration: const InputDecoration(
                  labelText: "Account Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'shop_owner', child: Text('Shop Owner')),
                  DropdownMenuItem(value: 'hospitality_owner', child: Text('Hospitality Owner')),
                  DropdownMenuItem(value: 'property_owner', child: Text('Property Owner')),
                ],
                onChanged: (v) => setState(() => _selectedUserType = v!),
              ),

              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                label: "Password",
                controller: _passwordController,
                type: TextFieldType.password,
                isRequired: true,
                prefix: const Icon(Icons.lock),
              ),

              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                label: "Confirm Password",
                controller: _confirmPasswordController,
                type: TextFieldType.password,
                isRequired: true,
                prefix: const Icon(Icons.lock),
              ),

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: auth.isLoading || _loading ? "Registering..." : "Register",
                  onPressed: auth.isLoading || _loading ? null : _handleRegister,
                  loading: auth.isLoading || _loading,
                  fullWidth: true,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
