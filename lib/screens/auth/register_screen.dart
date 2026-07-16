import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedDistrict;

  // Defaults to "shop_owner" as requested (Hidden from user selection)
  final String _selectedUserType = 'shop_owner';
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  final List<String> _districts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba","Others",
  ];

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = ref.read(authProvider.notifier);

      await auth.register(
        username: _usernameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        userType: _selectedUserType,
        district: _selectedDistrict,
        gender: null, // Hidden as requested
        dateOfBirth: null, // Hidden as requested
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
    final authState = ref.watch(authProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTabletOrWeb = screenWidth > 650;

    // Responsive width computations for dual-column field display (on large screens)
    final double paddingValue = isTabletOrWeb ? 40.0 : 20.0;
    final double maxCardWidth = 720.0;
    final double availableFormWidth = (screenWidth > maxCardWidth ? maxCardWidth : screenWidth) - (paddingValue * 2);
    final double itemWidth = isTabletOrWeb 
        ? (availableFormWidth - AppSpacing.md) / 2 
        : availableFormWidth;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 🌟 Matches the gorgeous orange gradient of LoginScreen
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
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxCardWidth),
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
                    padding: EdgeInsets.all(paddingValue),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 🌟 Header Typography
                          Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Join MalaTrade to start showcasing your offerings',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 🌟 Responsive Grid Wrap Form Fields
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            children: [
                              SizedBox(
                                width: itemWidth,
                                child: AppTextField(
                                  label: "Username",
                                  controller: _usernameController,
                                  isRequired: true,
                                  prefix: const Icon(Icons.person_outline, color: Colors.grey),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Username is required";
                                    }
                                    if (value.trim().length < 3) {
                                      return "Must be at least 3 characters";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: AppTextField(
                                  label: "First Name",
                                  controller: _firstNameController,
                                  isRequired: true,
                                  prefix: const Icon(Icons.badge_outlined, color: Colors.grey),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "First name is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: AppTextField(
                                  label: "Last Name",
                                  controller: _lastNameController,
                                  isRequired: true,
                                  prefix: const Icon(Icons.badge_outlined, color: Colors.grey),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Last name is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: AppTextField(
                                  label: "Email Address",
                                  controller: _emailController,
                                  type: TextFieldType.email,
                                  isRequired: true,
                                  prefix: const Icon(Icons.mail_outline, color: Colors.grey),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Email is required";
                                    }
                                    if (!value.contains("@")) {
                                      return "Enter a valid email address";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedDistrict,
                                  decoration: InputDecoration(
                                    labelText: "District",
                                    labelStyle: TextStyle(color: Colors.grey.shade600),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.map_outlined, color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: _districts
                                      .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedDistrict = v),
                                  validator: (value) {
                                    if (value == null) return "Select your district";
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AppTextField(
                                      label: "Phone Number (WhatsApp)",
                                      hint: '+265993344416',
                                      controller: _phoneController,
                                      type: TextFieldType.phone,
                                      isRequired: true,
                                      prefix: const Icon(Icons.phone_outlined, color: Colors.grey),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "WhatsApp number is required";
                                        }
                                        final phone = value.trim().replaceAll(' ', '');
                                        if (!phone.startsWith('+')) {
                                          return "Include country code (e.g. +265881234567)";
                                        }
                                        final regex = RegExp(r'^\+[1-9]\d{7,14}$');
                                        if (!regex.hasMatch(phone)) {
                                          return "Enter a valid international number";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    // 🌟 Informational Security & Trading communication Helper Label
                                    Text(
                                      "⚠️ Used directly for customer/seller communication during trade transactions.",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: AppTextField(
                                  label: "Password",
                                  controller: _passwordController,
                                  type: TextFieldType.password,
                                  isRequired: true,
                                  prefix: const Icon(Icons.lock_outline, color: Colors.grey),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Password is required";
                                    }
                                    if (value.length < 6) {
                                      return "Must be at least 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: AppTextField(
                                  label: "Confirm Password",
                                  controller: _confirmPasswordController,
                                  type: TextFieldType.password,
                                  isRequired: true,
                                  prefix: const Icon(Icons.lock_outline, color: Colors.grey),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Confirm password is required";
                                    }
                                    if (value != _passwordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // 🌟 Submit Registration Trigger Action Pipeline
                          AppButton(
                            text: authState.isLoading || _loading
                                ? "Registering..."
                                : "Register Now",
                            onPressed: authState.isLoading || _loading
                                ? null
                                : _handleRegister,
                            loading: authState.isLoading || _loading,
                            fullWidth: true,
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // 🌟 Footer redirection logic wrapper
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  "Login",
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}