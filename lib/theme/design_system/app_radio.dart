import 'package:flutter/material.dart';
import 'app_spacing.dart';

class AppRadio<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final void Function(T?)? onChanged;
  final String? description;
  final bool enabled;
  final Color? activeColor;

  const AppRadio({
    Key? key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.description,
    this.enabled = true,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: enabled ? onChanged : null,
            activeColor: activeColor ?? theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    description!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
