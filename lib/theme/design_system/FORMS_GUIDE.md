# AppTextField Component Guide

## Overview
`AppTextField` is a professional, reusable text input component with built-in validation, password visibility toggle, and comprehensive styling options.

## Basic Usage

```dart
import 'package:flutter/material.dart';
import '../../theme/design_system/app_text_field.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: _emailController,
          type: TextFieldType.email,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Password',
          controller: _passwordController,
          type: TextFieldType.password,
          isRequired: true,
        ),
      ],
    );
  }
}
```

## TextFieldType Options

- `TextFieldType.text` - Default text input
- `TextFieldType.email` - Email keyboard layout
- `TextFieldType.password` - Hidden text with visibility toggle
- `TextFieldType.number` - Numeric keyboard
- `TextFieldType.phone` - Phone keyboard
- `TextFieldType.url` - URL keyboard
- `TextFieldType.multiline` - Multi-line text area

## Common Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | String | Required | Field label text |
| `hint` | String | null | Placeholder text |
| `controller` | TextEditingController | null | Control field value |
| `type` | TextFieldType | text | Input type (email, password, etc.) |
| `maxLines` | int | 1 | Maximum lines (multiline only) |
| `validator` | Function | null | Custom validation function |
| `isRequired` | bool | false | Show required asterisk (*) |
| `onChanged` | Function | null | Called when value changes |
| `prefix` | Widget | null | Icon/widget before text |
| `suffix` | Widget | null | Icon/widget after text |
| `readOnly` | bool | false | Prevent user editing |
| `enabled` | bool | true | Enable/disable field |

## Validation Example

```dart
AppTextField(
  label: 'Email',
  controller: _emailController,
  type: TextFieldType.email,
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
)
```

## With Prefix/Suffix Icons

```dart
AppTextField(
  label: 'Username',
  controller: _usernameController,
  prefix: Icon(Icons.person),
  suffix: Icon(Icons.check_circle),
)
```

---

# AppDropdown Component Guide

## Basic Usage

```dart
String? selectedCategory;

AppDropdown<String>(
  label: 'Category',
  hint: 'Select a category',
  value: selectedCategory,
  items: [
    DropdownMenuItem(
      value: 'electronics',
      child: Text('Electronics'),
    ),
    DropdownMenuItem(
      value: 'fashion',
      child: Text('Fashion'),
    ),
    DropdownMenuItem(
      value: 'groceries',
      child: Text('Groceries'),
    ),
  ],
  onChanged: (value) {
    setState(() => selectedCategory = value);
  },
  isRequired: true,
)
```

## Helper Method for Creating Items

```dart
List<DropdownMenuItem<String>> _buildCategoryItems() {
  final categories = ['Electronics', 'Fashion', 'Groceries', 'Home', 'Beauty'];
  return categories
      .map((cat) => DropdownMenuItem(
        value: cat,
        child: Text(cat),
      ))
      .toList();
}

// Usage
AppDropdown<String>(
  label: 'Category',
  value: selectedCategory,
  items: _buildCategoryItems(),
  onChanged: (value) => setState(() => selectedCategory = value),
)
```

---

# AppCheckbox Component Guide

## Basic Usage

```dart
bool _agreeToTerms = false;

AppCheckbox(
  label: 'I agree to the terms and conditions',
  value: _agreeToTerms,
  onChanged: (value) {
    setState(() => _agreeToTerms = value ?? false);
  },
)
```

## With Description

```dart
AppCheckbox(
  label: 'Enable notifications',
  description: 'Receive updates about your orders',
  value: _enableNotifications,
  onChanged: (value) {
    setState(() => _enableNotifications = value ?? false);
  },
)
```

---

# AppRadio Component Guide

## Basic Usage

```dart
String _userType = 'customer';

Column(
  children: [
    AppRadio<String>(
      label: 'Customer',
      value: 'customer',
      groupValue: _userType,
      onChanged: (value) {
        setState(() => _userType = value ?? 'customer');
      },
    ),
    AppRadio<String>(
      label: 'Seller',
      value: 'seller',
      groupValue: _userType,
      onChanged: (value) {
        setState(() => _userType = value ?? 'customer');
      },
    ),
  ],
)
```

---

# AppFormSection Component Guide

## Basic Usage

```dart
AppFormSection(
  title: 'Personal Information',
  description: 'Tell us about yourself',
  children: [
    AppTextField(
      label: 'First Name',
      controller: _firstNameController,
    ),
    const SizedBox(height: 16),
    AppTextField(
      label: 'Last Name',
      controller: _lastNameController,
    ),
  ],
)
```

---

# Form Helpers Guide

## FormFieldSpacing

Automatically adds spacing between form fields:

```dart
FormFieldSpacing(
  child: AppTextField(
    label: 'Email',
    controller: _emailController,
  ),
)
```

## FormValidationMessage

Show validation success or error messages:

```dart
FormValidationMessage(
  message: 'Email is valid',
  isError: false,
),
```

## FormFieldHint

Show helper text below fields:

```dart
Column(
  children: [
    AppTextField(
      label: 'Password',
      controller: _passwordController,
      type: TextFieldType.password,
    ),
    FormFieldHint(
      text: 'Password must be at least 8 characters',
    ),
  ],
)
```

## FormActions

Container for form action buttons:

```dart
FormActions(
  primary: ElevatedButton(
    onPressed: () => _submitForm(),
    child: Text('Submit'),
  ),
  secondary: OutlinedButton(
    onPressed: () => Navigator.pop(context),
    child: Text('Cancel'),
  ),
)
```

---

# Complete Form Example

```dart
import 'package:flutter/material.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_dropdown.dart';
import '../../theme/design_system/app_checkbox.dart';
import '../../theme/design_system/app_form_section.dart';
import '../../theme/design_system/app_form_helpers.dart';

class CompleteFormExample extends StatefulWidget {
  @override
  State<CompleteFormExample> createState() => _CompleteFormExampleState();
}

class _CompleteFormExampleState extends State<CompleteFormExample> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  String? _selectedCategory;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to the terms')),
      );
      return;
    }

    // Submit form logic here
    print('Form submitted successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Professional Form')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Personal Information Section
              AppFormSection(
                title: 'Personal Information',
                description: 'Please provide your details',
                children: [
                  FormFieldSpacing(
                    child: AppTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  FormFieldSpacing(
                    child: AppTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      type: TextFieldType.email,
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
                      label: 'Phone',
                      hint: 'Enter your phone number',
                      controller: _phoneController,
                      type: TextFieldType.phone,
                      isRequired: true,
                    ),
                  ),
                ],
              ),

              // Category Section
              AppFormSection(
                title: 'Preferences',
                description: 'Select your preferences',
                children: [
                  AppDropdown<String>(
                    label: 'Category',
                    hint: 'Select a category',
                    value: _selectedCategory,
                    items: ['Electronics', 'Fashion', 'Groceries', 'Home']
                        .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    isRequired: true,
                  ),
                ],
              ),

              // Agreement Section
              AppFormSection(
                title: 'Agreement',
                showDivider: false,
                children: [
                  AppCheckbox(
                    label: 'I agree to the terms and conditions',
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value ?? false);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              FormActions(
                primary: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
                secondary: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Always use TextEditingController** - Dispose them in the `dispose()` method
2. **Wrap with Form** - Use `GlobalKey<FormState>()` for validation
3. **Use validators** - Provide custom validators for important fields
4. **Group related fields** - Use `AppFormSection` for logical grouping
5. **Add spacing** - Use `FormFieldSpacing` or `SizedBox` between fields
6. **Show required indicator** - Set `isRequired: true` for mandatory fields
7. **Provide hints** - Help users understand what to enter
8. **Handle validation** - Always check form validity before submission
9. **Use appropriate types** - Match `TextFieldType` to the input (email, password, etc.)
10. **Consistent spacing** - Use `AppSpacing` constants for consistency
