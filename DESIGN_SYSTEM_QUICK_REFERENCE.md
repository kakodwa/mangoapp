# Design System Quick Reference - Post Migration

This guide shows you how to use the design system consistently across all screens after the theme migration.

## Color System

### Using Theme Colors
```dart
// Always use theme colors instead of hardcoded Colors
Color primaryColor = Theme.of(context).colorScheme.primary;      // MangoOrange
Color secondaryColor = Theme.of(context).colorScheme.secondary;  // LeafGreen
Color surfaceColor = Theme.of(context).colorScheme.surface;      // White/Background
Color textColor = Theme.of(context).colorScheme.onSurface;       // DarkText
Color errorColor = Theme.of(context).colorScheme.error;          // Error states
Color outlineColor = Theme.of(context).colorScheme.outline;      // Borders/dividers
```

### Semantic Color Helpers
```dart
import '../../theme/app_colors.dart';

// Static color values (when you need them)
Color orange = AppColors.mangoOrange;
Color green = AppColors.leafGreen;
Color darkText = AppColors.darkText;

// Context-aware functions
Color primary = AppColors.primary(context);
Color secondary = AppColors.secondary(context);
Color error = AppColors.error(context);
Color text = AppColors.text(context);
```

## Spacing System

### Standard Spacing Scale
```dart
import '../../theme/design_system/app_spacing.dart';

AppSpacing.xxs   // 4px  - Extra small (gaps, tiny margins)
AppSpacing.xs    // 8px  - Extra small (padding around icons)
AppSpacing.sm    // 12px - Small (input field padding)
AppSpacing.md    // 16px - Medium (standard padding/margin)
AppSpacing.lg    // 24px - Large (section spacing)
AppSpacing.xl    // 32px - Extra large (major sections)
AppSpacing.xxl   // 48px - Extra extra large (page spacing)
```

### Using Spacing in Layouts
```dart
// Padding
Container(
  padding: const EdgeInsets.all(AppSpacing.md),  // All sides
  child: child,
)

// Symmetric padding
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,  // Left and right
    vertical: AppSpacing.md,    // Top and bottom
  ),
  child: child,
)

// SizedBox spacing
const SizedBox(height: AppSpacing.lg)  // Vertical spacing
const SizedBox(width: AppSpacing.md)   // Horizontal spacing

// ListTile padding
ListView(
  padding: const EdgeInsets.all(AppSpacing.md),
  itemCount: items.length,
  itemBuilder: (context, index) => items[index],
)
```

## Typography System

### Text Styles
```dart
import '../../theme/design_system/app_typography.dart';

// Display styles (large headings, 24-32px)
Text('Page Title', style: AppTypography.displayLarge)
Text('Section Title', style: AppTypography.displayMedium)
Text('Heading', style: AppTypography.displaySmall)

// Headline styles (medium headings, 16-20px)
Text('Card Title', style: AppTypography.headlineLarge)
Text('Subtitle', style: AppTypography.headlineMedium)
Text('Label', style: AppTypography.headlineSmall)

// Title styles (smaller headings, 14-16px)
Text('Item Name', style: AppTypography.titleLarge)
Text('Category', style: AppTypography.titleMedium)

// Body styles (regular text, 12-16px)
Text('Description', style: AppTypography.bodyLarge)
Text('Content', style: AppTypography.bodyMedium)
Text('Details', style: AppTypography.bodySmall)

// Label and button styles
Text('Label', style: AppTypography.labelMedium)
Text('Button Text', style: AppTypography.buttonText)
```

### Theme Text Styles
```dart
// Use theme text styles with color customization
Text(
  'Subtitle',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.w600,
  ),
)
```

## Design System Components

### AppButton
```dart
import '../../theme/design_system/app_button.dart';

AppButton(
  text: 'Click Me',
  onPressed: () => handleClick(),
  loading: false,
  fullWidth: true,
)

AppButton(
  text: 'Delete',
  onPressed: () => handleDelete(),
  variant: 'secondary',  // alternate style
)
```

### AppTextField
```dart
import '../../theme/design_system/app_text_field.dart';

AppTextField(
  label: 'Username',
  hint: 'Enter your username',
  controller: _controller,
  prefix: const Icon(Icons.person),
  isRequired: true,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Username is required';
    }
    return null;
  },
)

// Password field
AppTextField(
  label: 'Password',
  controller: _passwordController,
  type: TextFieldType.password,
  prefix: const Icon(Icons.lock),
  isRequired: true,
)

// Email field
AppTextField(
  label: 'Email',
  controller: _emailController,
  type: TextFieldType.email,
  prefix: const Icon(Icons.email),
  isRequired: true,
)
```

### AppCard
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ],
  ),
  child: content,
)
```

## Common Patterns

### Container with Theme Background
```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
  ),
  child: child,
)
```

### Divider
```dart
Divider(
  color: Theme.of(context).colorScheme.outline,
  thickness: 1,
  height: AppSpacing.lg,
)
```

### List Item with Theme Colors
```dart
ListTile(
  leading: Icon(
    Icons.shopping_bag,
    color: Theme.of(context).colorScheme.primary,
  ),
  title: Text('Product Name'),
  subtitle: Text(
    'Description',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  ),
  trailing: Icon(
    Icons.arrow_forward,
    color: Theme.of(context).colorScheme.outline,
  ),
)
```

### Error/Success Messages
```dart
// Error message
Text(
  'Something went wrong',
  style: TextStyle(
    color: Theme.of(context).colorScheme.error,
    fontWeight: FontWeight.w500,
  ),
)

// Success message
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Theme.of(context).colorScheme.secondary,
    ),
  ),
  child: Text(
    'Success!',
    style: TextStyle(
      color: Theme.of(context).colorScheme.secondary,
    ),
  ),
)
```

## DO's and DON'Ts

### DO
```dart
// ✅ Use theme colors
backgroundColor: Theme.of(context).colorScheme.surface

// ✅ Use AppSpacing constants
padding: const EdgeInsets.all(AppSpacing.md)

// ✅ Use typography system
style: AppTypography.bodyMedium

// ✅ Import design system
import '../../theme/design_system/app_spacing.dart';

// ✅ Use design components
AppButton(text: 'Click', onPressed: () {})
```

### DON'T
```dart
// ❌ Don't hardcode colors
backgroundColor: Colors.white
backgroundColor: Color(0xFFFFFFFF)

// ❌ Don't use arbitrary numbers for spacing
padding: const EdgeInsets.all(16)
padding: const EdgeInsets.all(24)

// ❌ Don't create custom TextStyles
style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)

// ❌ Don't create custom buttons
ElevatedButton(onPressed: () {}, child: Text('Click'))

// ❌ Don't use Colors directly
color: Colors.orange
color: Colors.green
color: Colors.grey[600]
```

## Migration Complete!
All 61 screens have been migrated to this design system. Any new screens or features should follow these patterns to maintain consistency across the entire app.

For more details, see `THEME_MIGRATION_SUMMARY.md`.
