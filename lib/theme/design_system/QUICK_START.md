# Design System Quick Start

Fast reference for building consistent UIs with MangoMart's design system.

## Essential Imports

```dart
import 'package:mangochi_marketplace/theme/design_system/index.dart';
```

This gives you access to all components.

## Common Patterns

### Button
```dart
AppButton(
  text: 'Confirm',
  onPressed: () {},
  fullWidth: true,
)
```

### Badge
```dart
AppBadge(
  text: 'New',
  type: BadgeType.success,
)
```

### Icon Button
```dart
AppIconButton(
  icon: Icons.favorite,
  onTap: () {},
  color: Colors.red,
)
```

### Spacing
```dart
// Instead of: padding: const EdgeInsets.all(16)
padding: AppSpacing.paddingMd

// Instead of: const SizedBox(height: 24)
const SizedBox(height: AppSpacing.lg)
```

### Colors
```dart
// Use theme colors
color: Theme.of(context).colorScheme.primary
backgroundColor: Theme.of(context).colorScheme.secondary
```

### Typography
```dart
// Page titles
style: theme.textTheme.displaySmall

// Section headers
style: theme.textTheme.headlineSmall

// Card titles
style: theme.textTheme.titleMedium

// Body text
style: theme.textTheme.bodyMedium

// Labels
style: theme.textTheme.labelSmall
```

## Card Examples

### Simple Card
```dart
AppCard(
  child: Text('Content'),
)
```

### Image Card
```dart
AppImageCard(
  imageUrl: 'https://...',
  height: 180,
)
```

### Titled Card
```dart
AppTitledCard(
  title: 'Product Name',
  subtitle: 'Category',
  image: AppImageCard(imageUrl: '...'),
  tags: [
    AppBadge(text: 'Popular'),
  ],
)
```

## Navigation with Animations

```dart
// Fade + Scale
Navigator.push(
  context,
  AppTransitions.fadeScaleRoute(NextPage()),
)

// Slide up
Navigator.push(
  context,
  AppTransitions.slideUpRoute(NextPage()),
)
```

## Shadow System

```dart
boxShadow: AppThemeExtensions.shadowSmall    // cards
boxShadow: AppThemeExtensions.shadowMedium   // default
boxShadow: AppThemeExtensions.shadowLarge    // modals
```

## Border Radius

```dart
borderRadius: BorderRadius.circular(AppThemeExtensions.radiusLarge)
// or use constants: radiusSmall, radiusMedium, radiusLarge, radiusXL
```

## Design Principles

1. **Use pre-defined values** - Don't hardcode numbers
2. **Theme colors** - Reference theme, not Colors class
3. **Spacing scale** - Only use AppSpacing values
4. **Reusable components** - Extract patterns into widgets
5. **Typography hierarchy** - Use text styles for structure

## Common Mistakes to Avoid

```dart
// ❌ Don't do this
padding: const EdgeInsets.all(14)
color: Colors.orange
height: 200
fontSize: 15

// ✅ Do this instead
padding: AppSpacing.paddingMd
color: Theme.of(context).colorScheme.primary
height: 180 // Use standard sizes
style: theme.textTheme.bodyMedium
```

## For More Details
See `../../DESIGN_SYSTEM.md` for comprehensive documentation.
