import 'package:flutter/material.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_dropdown.dart';
import '../../theme/design_system/app_checkbox.dart';
import '../../theme/design_system/app_radio.dart';
import '../../theme/design_system/app_form_section.dart';
import '../../theme/design_system/app_form_helpers.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_spacing.dart';

/// Complete example form demonstrating all new form components
/// This serves as a reference for refactoring existing forms
class ExampleCompleteFormScreen extends StatefulWidget {
  const ExampleCompleteFormScreen({Key? key}) : super(key: key);

  @override
  State<ExampleCompleteFormScreen> createState() =>
      _ExampleCompleteFormScreenState();
}

class _ExampleCompleteFormScreenState extends State<ExampleCompleteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'electronics';
  String _userType = 'customer';
  bool _agreeToTerms = false;
  bool _subscribeNewsletter = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = 'electronics';
          _userType = 'customer';
          _agreeToTerms = false;
          _subscribeNewsletter = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Form Example'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ============================================
              // PERSONAL INFORMATION SECTION
              // ============================================
              AppFormSection(
                title: 'Personal Information',
                description: 'Please provide your basic details',
                children: [
                  FormFieldSpacing(
                    child: AppTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      prefix: const Icon(Icons.person),
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name is required';
                        }
                        if ((value?.length ?? 0) < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  FormFieldSpacing(
                    child: AppTextField(
                      label: 'Email Address',
                      hint: 'example@email.com',
                      controller: _emailController,
                      type: TextFieldType.email,
                      prefix: const Icon(Icons.email),
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email is required';
                        }
                        if (!value!.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  FormFieldSpacing(
                    child: AppTextField(
                      label: 'Phone Number',
                      hint: '+265 123 456 789',
                      controller: _phoneController,
                      type: TextFieldType.phone,
                      prefix: const Icon(Icons.phone),
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // ============================================
              // CATEGORY & TYPE SECTION
              // ============================================
              AppFormSection(
                title: 'Preferences',
                description: 'Select your preferences',
                children: [
                  FormFieldSpacing(
                    child: AppDropdown<String>(
                      label: 'Category',
                      hint: 'Select a category',
                      value: _selectedCategory,
                      items: [
                        'Electronics',
                        'Fashion',
                        'Groceries',
                        'Home & Garden',
                        'Beauty & Health',
                      ]
                          .map((cat) => DropdownMenuItem(
                                value: cat.toLowerCase().replaceAll(' & ', '_'),
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value ?? 'electronics');
                      },
                      isRequired: true,
                    ),
                  ),
                  FormFieldSpacing(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Type',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppRadio<String>(
                          label: 'Customer',
                          description: 'I want to shop for products',
                          value: 'customer',
                          groupValue: _userType,
                          onChanged: (value) {
                            setState(() => _userType = value ?? 'customer');
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppRadio<String>(
                          label: 'Seller',
                          description: 'I want to sell products',
                          value: 'seller',
                          groupValue: _userType,
                          onChanged: (value) {
                            setState(() => _userType = value ?? 'customer');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ============================================
              // ADDITIONAL INFORMATION SECTION
              // ============================================
              AppFormSection(
                title: 'Additional Information',
                description: 'Tell us more about yourself',
                children: [
                  FormFieldSpacing(
                    child: AppTextField(
                      label: 'Description',
                      hint: 'Tell us about yourself or your business',
                      controller: _descriptionController,
                      type: TextFieldType.multiline,
                      maxLines: 4,
                      validator: (value) {
                        if ((value?.length ?? 0) < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // ============================================
              // CONSENT & PREFERENCES SECTION
              // ============================================
              AppFormSection(
                title: 'Consent & Preferences',
                description: 'Choose your communication preferences',
                showDivider: false,
                children: [
                  FormFieldSpacing(
                    child: AppCheckbox(
                      label: 'I agree to the Terms and Conditions',
                      description: 'Please read and accept our terms',
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() => _agreeToTerms = value ?? false);
                      },
                    ),
                  ),
                  FormFieldSpacing(
                    child: AppCheckbox(
                      label: 'Subscribe to our newsletter',
                      description: 'Receive updates about new products and offers',
                      value: _subscribeNewsletter,
                      onChanged: (value) {
                        setState(() => _subscribeNewsletter = value ?? false);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ============================================
              // ACTION BUTTONS
              // ============================================
              FormActions(
                primary: AppButton.primary(
                  label: _isLoading ? 'Submitting...' : 'Submit Form',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                ),
                secondary: AppButton.secondary(
                  label: 'Cancel',
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ============================================
              // FORM SUMMARY (For reference)
              // ============================================
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Data (for reference)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Name: ${_nameController.text.isEmpty ? "Not entered" : _nameController.text}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Email: ${_emailController.text.isEmpty ? "Not entered" : _emailController.text}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Phone: ${_phoneController.text.isEmpty ? "Not entered" : _phoneController.text}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Category: $_selectedCategory',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Type: $_userType',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Newsletter: $_subscribeNewsletter',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
