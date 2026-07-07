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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedGender;
  DateTime? _dateOfBirth;

  String _selectedUserType = 'customer';
  bool _loading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  final List<String> _districts = [
    "Balaka","Blantyre","Chikwawa","Chiradzulu","Chitipa","Dedza",
    "Dowa","Karonga","Kasungu","Likoma","Lilongwe","Machinga",
    "Mangochi","Mchinji","Mulanje","Mwanza","Mzimba","Neno",
    "Nkhata Bay","Nkhotakota","Nsanje","Ntcheu","Ntchisi",
    "Phalombe","Rumphi","Salima","Thyolo","Zomba",
  ];

  final List<String> _genders = [
    "Male",
    "Female",
    "Other",
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
        gender: _selectedGender,
        dateOfBirth: _dateOfBirth?.toIso8601String().split('T').first,
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
    
    // 1. Grab current screen details
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    // Check if we are on tablet/desktop layout breakpoint
    final isTabletOrWeb = screenWidth > 650;

    // 2. Calculate the optimal width per field for multi-column grids
    // On wide screens we split items into 2 columns, taking spacing into account
    final itemWidth = isTabletOrWeb 
        ? (screenWidth.clamp(0, 800) - (AppSpacing.md * 2) - AppSpacing.md) / 2 
        : screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("Create Account")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Container(
            // 3. Prevent the form from stretching uncomfortably wide on desktop
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 4. Wrap layout allows dynamic inline multi-column switching
                  Wrap(
                    spacing: AppSpacing.md, // horizontal gap between fields
                    runSpacing: AppSpacing.sm, // vertical gap between fields
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: AppTextField(
                          label: "Username",
                          controller: _usernameController,
                          isRequired: true,
                          prefix: const Icon(Icons.person),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Username is required";
                            }
                            if (value.trim().length < 3) {
                              return "Username must be at least 3 characters";
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
                          prefix: const Icon(Icons.person_outline),
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
                          prefix: const Icon(Icons.person_outline),
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
                          label: "Phone Number (WhatsApp)",
                          hint: '+265993344416',
                          controller: _phoneController,
                          type: TextFieldType.phone,
                          prefix: const Icon(Icons.phone),
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
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: AppTextField(
                          label: "Email",
                          controller: _emailController,
                          type: TextFieldType.email,
                          isRequired: true,
                          prefix: const Icon(Icons.email),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email is required";
                            }
                            if (!value.contains("@")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: DropdownButtonFormField<String>(
                          value: _selectedUserType,
                          decoration: const InputDecoration(
                            labelText: "Account Type",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'customer', child: Text('Customer')),
                            DropdownMenuItem(value: 'shop_owner', child: Text('Shop Owner')),
                            DropdownMenuItem(value: 'event_organizer', child: Text('Event Organizer')),
                            DropdownMenuItem(value: 'hospitality_owner', child: Text('Hospitality Owner')),
                            DropdownMenuItem(value: 'property_owner', child: Text('Property Owner')),
                          ],
                          onChanged: (v) => setState(() => _selectedUserType = v!),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: const InputDecoration(
                            labelText: "District",
                            border: OutlineInputBorder(),
                          ),
                          items: _districts
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedDistrict = v),
                          validator: (value) {
                            if (value == null) return "Select district";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: "Gender",
                            border: OutlineInputBorder(),
                          ),
                          items: _genders
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedGender = v),
                          validator: (value) {
                            if (value == null) return "Select gender";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: InkWell(
                          onTap: _pickDateOfBirth,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Date of Birth",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cake),
                            ),
                            child: Text(
                              _dateOfBirth == null
                                  ? "Select Date of Birth"
                                  : "${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: AppTextField(
                          label: "Password",
                          controller: _passwordController,
                          type: TextFieldType.password,
                          isRequired: true,
                          prefix: const Icon(Icons.lock),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
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
                          prefix: const Icon(Icons.lock),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm password";
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
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Bottom actions (keep centered/contained within the max-width frame)
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: auth.isLoading || _loading
                          ? "Registering..."
                          : "Register",
                      onPressed: auth.isLoading || _loading
                          ? null
                          : _handleRegister,
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
        ),
      ),
    );
  }
}