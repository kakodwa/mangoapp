import 'package:flutter/material.dart';

class AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const AmenityChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}