// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 🌟 Added to safely guard web-only execution
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌟 FIX: Swapped out dart:html for universal_html so compilation passes on Android
import 'package:universal_html/html.dart' as html; 

import '../screens/main_tabs_screen.dart'; 
import '../screens/splash_screen.dart'; 
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../main.dart' show globalNavigatorKey; 

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 🌟 Only execute web routing if we are explicitly running in a web browser
    if (kIsWeb) {
      _setupWebRouting();
    }
  }

  /// Configure web-specific routing to handle query parameters and hash routes
  void _setupWebRouting() {
    debugPrint('[WebRouting] Setting up web routing...');
    
    // Store current route for deep linking
    final currentUri = html.window.location;
    final currentPath = currentUri.pathname ?? '';
    final currentHash = currentUri.hash ?? '';
    final currentSearch = currentUri.search ?? '';
    
    debugPrint('[WebRouting] Current path: $currentPath');
    debugPrint('[WebRouting] Current hash: $currentHash');
    debugPrint('[WebRouting] Current search: $currentSearch');
    
    // Store path for MainTabsScreen to process after build
    if (currentPath.isNotEmpty && currentPath != '/') {
      html.window.localStorage['deferred_deep_link'] = currentPath;
      debugPrint('[WebRouting] Stored path in localStorage: $currentPath');
    } else if (currentHash.isNotEmpty && currentHash != '#') {
      // Handle hash-based routing (e.g., /#/product/2)
      final hashPath = currentHash.replaceFirst('#', '');
      html.window.localStorage['deferred_deep_link'] = hashPath;
      debugPrint('[WebRouting] Stored hash path in localStorage: $hashPath');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      navigatorKey: globalNavigatorKey, 
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