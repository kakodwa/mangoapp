// lib/app/app_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home/home_screen.dart';
import '../screens/shops/shops_list_screen.dart';
import '../screens/properties/properties_list_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/products/products_list_screen.dart';

final currentBottomNavIndexProvider =
    StateProvider<int>((ref) => 0);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  ConsumerState<AppShell> createState() =>
      _AppShellState();
}

class _AppShellState
    extends ConsumerState<AppShell> {
  late final List<Widget> _screens;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(),
      ShopsListScreen(),
      ProductsListScreen(),
      PropertiesListScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,

        onPageChanged: (index) {
          ref
              .read(
                currentBottomNavIndexProvider
                    .notifier,
              )
              .state = index;
        },

        children: _screens,
      ),
    );
  }
}