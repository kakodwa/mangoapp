import 'package:flutter/material.dart';
import 'app_spacing.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final bool isRequired;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? prefix;
  final TextStyle? labelStyle;

  const AppDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.enabled = true,
    this.prefix,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL
        Row(
          children: [
            Text(
              label,
              style: labelStyle ?? theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // DROPDOWN
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: prefix,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          isExpanded: true,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
