# MangoMart Design System

A comprehensive, reusable design system for the MangoMart marketplace app. This guide helps developers maintain visual consistency and build professional interfaces.

## Quick Start

Import components from the design system:

```dart
import 'package:mangochi_marketplace/theme/design_system/index.dart';
```

## Core Components

### Buttons

#### AppButton
Primary action buttons with multiple types and states.

```dart
AppButton(
  text: 'Checkout',
  onPressed: () {},
  fullWidth: true,
  type: AppButtonType.primary, // primary, secondary, outline
)
```

**Types:**
- `primary` - Main action button (orange)
- `secondary` - Alternative action (light orange)
- `outline` - Ghost button with border

#### AppIconButton
Circular icon buttons for secondary actions.

```dart
AppIconButton(
  icon: Icons.heart,
  onTap: () {},
  color: Colors.red,
  style: IconButtonStyle.filled, // filled, outlined, ghost
)
```

### Badges

#### AppBadge
Display categories, statuses, and tags.

```dart
AppBadge(
  text: 'Featured',
  type: BadgeType.primary, // primary, success, warning, error, info
)
```

### Cards

#### AppCard
Simple container with consistent shadow and padding.

```dart
AppCard(
  padding: AppSpacing.paddingMd,
  onTap: () {},
  child: Text('Content'),
)
```

#### AppImageCard
Image container with overlay and badge support.

```dart
AppImageCard(
  imageUrl: 'https://...',
  height: 180,
  badges: [
    AppBadge(text: 'New', type: BadgeType.success),
  ],
)
```

#### AppTitledCard
Card with title, subtitle, image, and tags.

```dart
AppTitledCard(
  title: 'Product Name',
  subtitle: 'Category',
  image: AppImageCard(imageUrl: '...'),
  tags: [
    AppBadge(text: 'Popular', type: BadgeType.info),
  ],
)
```

## Spacing System

Use the centralized spacing scale for consistent margins and padding:

```dart
// Direct values
AppSpacing.xs  // 8dp
AppSpacing.sm  // 12dp
AppSpacing.md  // 16dp
AppSpacing.lg  // 24dp
AppSpacing.xl  // 32dp
AppSpacing.xxl // 48dp

// Pre-defined padding
AppSpacing.paddingMd          // all sides
AppSpacing.paddingHorizontalMd // left/right
AppSpacing.paddingVerticalLg   // top/bottom
```

## Typography

Professional typography styles with consistent line-height and letter-spacing:

```dart
// Display (large headings)
AppTypography.displayLarge    // 32px, bold
AppTypography.displayMedium   // 28px, bold
AppTypography.displaySmall    // 24px, bold

// Headlines
AppTypography.headlineLarge   // 20px, w700
AppTypography.headlineMedium  // 18px, w700
AppTypography.headlineSmall   // 16px, w700

// Titles
AppTypography.titleLarge      // 16px, w600
AppTypography.titleMedium     // 14px, w600
AppTypography.titleSmall      // 13px, w600

// Body (default text)
AppTypography.bodyLarge       // 16px, regular
AppTypography.bodyMedium      // 14px, regular
AppTypography.bodySmall       // 12px, regular

// Labels
AppTypography.labelLarge      // 14px, w500
AppTypography.labelMedium     // 12px, w500
AppTypography.labelSmall      // 11px, w500

// Button Text
AppTypography.buttonText      // 15px, w600
AppTypography.buttonSmall     // 13px, w600
```

**Usage with Theme:**
```dart
Text(
  'Section Title',
  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    color: Colors.orange,
  ),
)
```

## Colors

The app uses a professional orange and green color scheme:

```dart
AppColors.mangoOrange  // Primary brand color (#FF8C00)
AppColors.mangoLight   // Light orange (#FFA726)
AppColors.leafGreen    // Secondary accent (#2E7D32)
AppColors.darkText     // Text color (#212121)
```

**Access theme colors dynamically:**
```dart
AppColors.primary(context)   // Current theme primary
AppColors.secondary(context) // Current theme secondary
AppColors.text(context)      // Current theme text color
```

## Shadows

Professional shadow system for elevation:

```dart
AppThemeExtensions.shadowSmall    // Subtle elevation
AppThemeExtensions.shadowMedium   // Default cards
AppThemeExtensions.shadowLarge    // Modals
AppThemeExtensions.shadowElevated // Floating elements
```

## Transitions & Animations

Built-in route transitions for consistent navigation:

```dart
// Fade + Scale (default, subtle)
Navigator.push(context, AppTransitions.fadeScaleRoute(NextPage()));

// Slide from right
Navigator.push(context, AppTransitions.slideRightRoute(NextPage()));

// Slide up (modal-like)
Navigator.push(context, AppTransitions.slideUpRoute(NextPage()));

// Smooth animations
SmoothAnimationBuilder(
  builder: (context, value) {
    return Opacity(opacity: value, child: child);
  },
)
```

## Border Radius

Consistent rounding across components:

```dart
AppThemeExtensions.radiusSmall   // 8dp
AppThemeExtensions.radiusMedium  // 12dp
AppThemeExtensions.radiusLarge   // 16dp
AppThemeExtensions.radiusXL      // 20dp
AppThemeExtensions.radiusCircle  // 50dp (circular)
```

## Best Practices

### 1. Use Theme Values
Always reference theme colors instead of hardcoding:

```dart
// ✅ Good
color: Theme.of(context).colorScheme.primary

// ❌ Avoid
color: Colors.orange
```

### 2. Consistent Spacing
Use the spacing scale, not arbitrary values:

```dart
// ✅ Good
padding: AppSpacing.paddingMd
const SizedBox(height: AppSpacing.lg)

// ❌ Avoid
padding: const EdgeInsets.all(14)
const SizedBox(height: 20)
```

### 3. Typography Hierarchy
Use typography styles to establish visual hierarchy:

```dart
// Page title
Text('Products', style: theme.textTheme.displaySmall)

// Section header
Text('Featured', style: theme.textTheme.headlineSmall)

// Card title
Text('Product Name', style: theme.textTheme.titleMedium)

// Body text
Text('Description', style: theme.textTheme.bodyMedium)

// Labels
Text('Category', style: theme.textTheme.labelSmall)
```

### 4. Reusable Components
Extract common patterns into components:

```dart
// Extract repeated UI patterns
class ProductTile extends StatelessWidget {
  final Product product;
  
  const ProductTile({required this.product});
  
  @override
  Widget build(BuildContext context) {
    return AppTitledCard(
      title: product.name,
      image: AppImageCard(imageUrl: product.image),
      // ... rest of component
    );
  }
}
```

## File Structure

```
lib/
  theme/
    app_colors.dart                    # Brand colors
    design_system/
      index.dart                       # Central exports
      app_button.dart                  # Button component
      app_badge.dart                   # Badge component
      app_card.dart                    # Simple card
      app_image_card.dart              # Image card
      app_titled_card.dart             # Titled card
      app_icon_button.dart             # Icon button
      app_typography.dart              # Typography styles
      app_spacing.dart                 # Spacing scale
      app_theme_extensions.dart        # Shadows, radius, etc
      app_transitions.dart             # Route transitions
      app_loader.dart                  # Loading states
      app_info_box.dart                # Info component
      app_button.dart                  # Button styles
```

## Example: Complete Product Card

```dart
import 'package:mangochi_marketplace/theme/design_system/index.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({required this.product});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        AppTransitions.fadeScaleRoute(ProductDetailsScreen(product: product)),
      ),
      child: AppTitledCard(
        title: product.name,
        subtitle: product.category,
        image: AppImageCard(
          imageUrl: product.imageUrl,
          height: 150,
          badges: [
            if (product.isNew)
              AppBadge(text: 'New', type: BadgeType.success),
          ],
        ),
        tags: [
          AppBadge(text: '${product.price} MWK', type: BadgeType.primary),
        ],
        trailing: AppIconButton(
          icon: Icons.shopping_cart,
          onTap: () => addToCart(product),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
```

## Updating the Design System

When adding new components:

1. Create component file in `lib/theme/design_system/`
2. Add to `index.dart` exports
3. Document in this file with usage examples
4. Use consistent naming: `App*` prefix
5. Support theme customization
6. Include comments with examples

## Questions or Contributions?

Maintain consistency by following these patterns. The design system is designed to be extended as the app grows.
