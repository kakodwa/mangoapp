import 'package:flutter/material.dart';
import 'app_spacing.dart';

/// Helper widget for form field spacing
class FormFieldSpacing extends StatelessWidget {
  final Widget child;
  final double spacing;

  const FormFieldSpacing({
    Key? key,
    required this.child,
    this.spacing = AppSpacing.md,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: child,
    );
  }
}

/// Helper widget for form validation messages
class FormValidationMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const FormValidationMessage({
    Key? key,
    required this.message,
    this.isError = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError ? Colors.red : Colors.green.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for form field help text
class FormFieldHint extends StatelessWidget {
  final String text;
  final Color? color;

  const FormFieldHint({
    Key? key,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color ?? Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Helper widget for form divider between sections
class FormDivider extends StatelessWidget {
  final double spacing;

  const FormDivider({
    Key? key,
    this.spacing = AppSpacing.lg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Divider(
        color: Colors.grey.shade300,
        height: 1,
      ),
    );
  }
}

/// Form action buttons container
class FormActions extends StatelessWidget {
  final Widget? primary;
  final Widget? secondary;
  final MainAxisAlignment alignment;
  final double spacing;

  const FormActions({
    Key? key,
    this.primary,
    this.secondary,
    this.alignment = MainAxisAlignment.end,
    this.spacing = AppSpacing.md,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (secondary != null) ...[
          Expanded(child: secondary!),
          SizedBox(width: spacing),
        ],
        if (primary != null)
          Expanded(flex: secondary != null ? 1 : 0, child: primary!),
      ],
    );
  }
}
