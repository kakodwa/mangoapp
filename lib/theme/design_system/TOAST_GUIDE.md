# AppToast - Professional Notification System

## Overview

AppToast is a professional notification/toast system that matches the MangoMart design system. It provides beautiful, consistent notifications across your entire app with multiple toast types, customization options, and accessibility features.

## Features

- 4 Toast Types: Success, Error, Warning, Info
- Progress bar showing auto-dismiss countdown
- Dismissible notifications with close button
- Icon indicators for each type
- Title and description support
- Custom styling with theme integration
- Flexible duration control
- Optional tap callbacks
- Professional animations
- Mobile-optimized positioning
- Progress indicators
- Theme-aware colors

## Basic Usage

### Success Toast

```dart
AppToast.success(context, 'Product added to cart');
```

### Error Toast

```dart
AppToast.error(context, 'Failed to add product');
```

### Warning Toast

```dart
AppToast.warning(context, 'Low stock available');
```

### Info Toast

```dart
AppToast.info(context, 'Order placed successfully');
```

## Advanced Usage

### With Custom Title

```dart
AppToast.success(
  context,
  'Product has been created',
  title: 'Success',
);
```

### Custom Duration

```dart
AppToast.info(
  context,
  'This will stay for 10 seconds',
  duration: const Duration(seconds: 10),
);
```

### Non-Dismissible Toast

```dart
AppToast.info(
  context,
  'Processing your order...',
  dismissible: false,
);
```

### With Callback

```dart
AppToast.custom(
  context,
  message: 'Undo last action?',
  type: ToastType.info,
  onTap: () {
    // Handle undo action
    print('Undo tapped');
  },
);
```

### Full Custom Control

```dart
AppToast.custom(
  context,
  title: 'Custom Toast',
  message: 'This is a fully customized notification',
  type: ToastType.warning,
  duration: const Duration(seconds: 6),
  dismissible: true,
  leading: const Icon(Icons.star),
  onTap: () {
    // Handle tap
  },
);
```

## Toast Types

### Success (Green - #10B981)
- Use when an action completes successfully
- Default duration: 4 seconds
- Icon: Check mark
- Examples: "Product added", "Payment successful", "Profile updated"

### Error (Red - #EF4444)
- Use when an action fails
- Default duration: 5 seconds (longer to read error details)
- Icon: Error symbol
- Examples: "Payment failed", "Network error", "Validation error"

### Warning (Orange - #F59E0B)
- Use for cautionary messages
- Default duration: 4 seconds
- Icon: Warning triangle
- Examples: "Low stock", "Incomplete data", "Unsaved changes"

### Info (Blue - #3B82F6)
- Use for informational messages
- Default duration: 4 seconds
- Icon: Info circle
- Examples: "Order placed", "Email sent", "File downloaded"

## Styling

### Position
Toasts appear in the top-right corner with proper margin (AppSpacing.md).

### Colors
Each toast type has a professional color scheme:
- Success: Green (#10B981)
- Error: Red (#EF4444)
- Warning: Orange (#F59E0B)
- Info: Blue (#3B82F6)

### Animations
- Fade-in animation on appear
- Progress bar countdown animation
- Smooth dismiss animation

### Shadow
Professional shadow effect for depth: `BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16)`

## Real-World Examples

### Form Validation

```dart
void _submitForm() {
  if (_email.isEmpty) {
    AppToast.error(context, 'Please enter your email');
    return;
  }
  
  if (_password.length < 8) {
    AppToast.warning(context, 'Password must be at least 8 characters');
    return;
  }
  
  // Submit form
  AppToast.success(context, 'Account created successfully');
}
```

### API Request Handling

```dart
Future<void> _fetchData() async {
  try {
    final response = await _api.getData();
    AppToast.success(context, 'Data loaded successfully');
  } catch (e) {
    AppToast.error(
      context,
      'Failed to load data. Please try again.',
      title: 'Error',
    );
  }
}
```

### Cart Operations

```dart
void _addToCart(Product product) {
  try {
    cart.add(product);
    AppToast.success(
      context,
      '${product.name} added to cart',
      title: 'Added to Cart',
    );
  } catch (e) {
    AppToast.error(context, 'Could not add to cart');
  }
}
```

### Payment Processing

```dart
void _processPayment() {
  AppToast.info(
    context,
    'Processing your payment...',
    dismissible: false,
  );
  
  _payment.process().then((_) {
    AppToast.success(
      context,
      'Payment successful!',
      title: 'Success',
    );
  }).catchError((e) {
    AppToast.error(
      context,
      'Payment failed. Please try again.',
      title: 'Payment Error',
    );
  });
}
```

### User Actions

```dart
void _deleteAccount() {
  AppToast.custom(
    context,
    message: 'Account deleted successfully',
    type: ToastType.success,
    title: 'Account Deleted',
  );
}

void _undoAction() {
  AppToast.custom(
    context,
    title: 'Undo Available',
    message: 'Tap to undo the last action',
    type: ToastType.info,
    onTap: () {
      _undo();
      AppToast.success(context, 'Action undone');
    },
  );
}
```

## API Reference

### `AppToast.success()`

```dart
static void success(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
  bool dismissible = true,
})
```

Shows a success toast with a green background.

### `AppToast.error()`

```dart
static void error(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 5),
  bool dismissible = true,
})
```

Shows an error toast with a red background. Duration defaults to 5 seconds to allow users to read longer error messages.

### `AppToast.warning()`

```dart
static void warning(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
  bool dismissible = true,
})
```

Shows a warning toast with an orange background.

### `AppToast.info()`

```dart
static void info(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
  bool dismissible = true,
})
```

Shows an info toast with a blue background.

### `AppToast.custom()`

```dart
static void custom(
  BuildContext context, {
  required String message,
  String? title,
  required ToastType type,
  Duration duration = const Duration(seconds: 4),
  bool dismissible = true,
  Widget? leading,
  VoidCallback? onTap,
})
```

Shows a fully customized toast with all options available.

## Toast Enum

```dart
enum ToastType { 
  success,  // Green
  error,    // Red
  warning,  // Orange
  info      // Blue
}
```

## Design System Integration

The AppToast system integrates with the MangoMart design system:

- Uses `AppSpacing` for margins and padding
- Integrates with `AppTypography` for text styling
- Respects theme colors and styling
- Matches professional animation patterns
- Follows accessibility guidelines

## Accessibility

- Icons clearly indicate toast type
- High contrast colors for readability
- Close button for manual dismissal
- Descriptive icons for screen readers
- Proper text sizing for visibility

## Best Practices

1. **Be Concise**: Keep messages short and clear (under 100 characters)
2. **Use Proper Type**: Choose the correct toast type for the message
3. **Don't Spam**: Avoid showing multiple toasts rapidly
4. **User Control**: Always allow dismissal unless critical
5. **Appropriate Duration**: Let error toasts stay longer than success
6. **Title + Message**: Use title for categorization, message for details
7. **Error Details**: For errors, include what went wrong and suggested fix
8. **Action Items**: Only use onTap for important actions

## Migration from Old AppToast

The old AppToast methods still work but are now backed by the new system:

```dart
// Old way (still works)
AppToast.success(context, 'Message');

// New way (more options)
AppToast.success(
  context,
  'Message',
  title: 'Title',
  duration: const Duration(seconds: 6),
);

// Full customization
AppToast.custom(
  context,
  message: 'Custom message',
  type: ToastType.success,
  // ... more options
);
```

All existing code continues to work. Gradually migrate to the new patterns as you refactor screens.

## Troubleshooting

### Toast not appearing?
- Ensure you're passing `BuildContext` from a widget with a ScaffoldMessenger ancestor
- Check that toastification package is imported in pubspec.yaml

### Multiple toasts at once?
- Use `toastification.dismiss()` to close previous toasts
- Or adjust the duration to prevent overlap

### Need notification persistence?
- Use `dismissible: false` and custom logic
- Or implement a custom notification system for critical messages

## Related Components

- **AppButton** - Primary action button
- **AppTextField** - Form input field
- **AppBadge** - Status indicator
- **AppFormHelpers** - Form validation messages (different from toasts)

## Future Enhancements

Potential improvements for future versions:
- Toast queue management
- Custom animation styles
- Swipe-to-dismiss gesture
- Toast history/log
- Sound/haptic feedback options
- Position customization
- Theme customization per toast
