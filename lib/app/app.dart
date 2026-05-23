<<<<<<< HEAD
// lib/app/app_shell.dart

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home/home_screen.dart';
import '../screens/shops/shops_list_screen.dart';
import '../screens/properties/properties_list_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/products/products_list_screen.dart';

<<<<<<< HEAD
final currentBottomNavIndexProvider =
    StateProvider<int>((ref) => 0);
=======
import '../providers/products_provider.dart';
import '../screens/cart/cart_screen.dart';

final currentBottomNavIndexProvider = StateProvider<int>((ref) => 0);
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    // 🚨 IMPORTANT: NO ThemeData here anymore
    // This MUST come from main.dart only
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    return const AppShell();
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
<<<<<<< HEAD
  ConsumerState<AppShell> createState() =>
      _AppShellState();
}

class _AppShellState
    extends ConsumerState<AppShell> {
=======
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD
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
=======
    final currentIndex = ref.watch(currentBottomNavIndexProvider);
    final cartItems = ref.watch(cartProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(currentBottomNavIndexProvider.notifier).state = index;
        },
        children: _screens,
      ),

      // =========================
      // 🧭 BOTTOM NAV (THEME FIXED)
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,

        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),

        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'Properties',
          ),
        ],
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      ),
    );
  }
}