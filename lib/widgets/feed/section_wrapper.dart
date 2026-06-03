import 'package:flutter/material.dart';

class SectionWrapper extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  final Widget child;

  const SectionWrapper({
    super.key,
    required this.title,
    required this.onViewAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'View All',
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}