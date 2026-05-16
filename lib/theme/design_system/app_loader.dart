// lib/theme/design_system/app_loader.dart

import 'package:flutter/material.dart';

class AppLoader {
  AppLoader._();

  /// Full screen loader (rare use)
  static Widget fullScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Inline loader (for sections)
  static Widget inline() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Skeleton card loader (simple version)
  static Widget cardSkeleton() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Grid skeleton loader
  static Widget gridSkeleton() {
    return GridView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}