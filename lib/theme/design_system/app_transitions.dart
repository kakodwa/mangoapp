import 'package:flutter/material.dart';

class AppTransitions {
  AppTransitions._();

  // Standard route transition with fade and scale
  static PageRoute<T> fadeScaleRoute<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 250),
    double beginScale = 0.95,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: beginScale, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // Slide from right route
  static PageRoute<T> slideRightRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  // Slide from left route
  static PageRoute<T> slideLeftRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  // Slide up route (modal-like)
  static PageRoute<T> slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // Fade only transition (subtle)
  static PageRoute<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Shared axis transition (useful for list items)
  static PageRoute<T> sharedAxisRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const double beginValue = 0.85;
        
        return ScaleTransition(
          scale: Tween<double>(begin: beginValue, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

// Helper for smooth animations
class SmoothAnimationBuilder extends StatelessWidget {
  final Widget Function(BuildContext, double) builder;
  final Duration duration;
  final Curve curve;
  final double beginValue;
  final double endValue;

  const SmoothAnimationBuilder({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.beginValue = 0.0,
    this.endValue = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginValue, end: endValue),
      duration: duration,
      curve: curve,
      builder: builder,
    );
  }
}
