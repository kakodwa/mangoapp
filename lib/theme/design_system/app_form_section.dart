import 'package:flutter/material.dart';
import 'app_spacing.dart';

class AppFormSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;
  final bool showDivider;

  const AppFormSection({
    Key? key,
    required this.title,
    this.description,
    required this.children,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            description!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...children,
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.lg),
          Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
