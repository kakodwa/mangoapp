// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/main_tabs_screen.dart'; 
import '../screens/splash_screen.dart'; 
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

// 🌟 FIX: Removed duplicate AppRouterMixin to prevent state lifecycle collision loops!
class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        colorScheme: const ColorScheme.light(
          primary: AppColors.mangoOrange,
          secondary: AppColors.leafGreen,
          onSurface: AppColors.darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkText,
          elevation: 0,
        ),
      ),
      home: authState.isLoading
          ? const SplashScreen()
          : const MainTabsScreen(), 
    );
  }
}