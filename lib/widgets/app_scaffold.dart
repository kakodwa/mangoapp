// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/shops/shops_list_screen.dart';
import '../screens/products/products_list_screen.dart';
import '../screens/properties/properties_list_screen.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final int currentIndex;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const AppScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.drawer,
    this.currentIndex = 0,
    this.backgroundColor,
    this.floatingActionButton,
  }) : super(key: key);

  void _navigateToTab(BuildContext context, int index) {
    Widget screen;

    switch (index) {
      case 0:
        screen = HomeScreen();
        break;

      case 1:
        screen = ShopsListScreen();
        break;

      case 2:
        screen = ProductsListScreen();
        break;

      case 3:
        screen = PropertiesListScreen();
        break;

      default:
        screen = HomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: appBar,

      drawer: drawer,

      backgroundColor: backgroundColor,

      floatingActionButton: floatingActionButton,

      body: SafeArea(
        child: body,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,

        selectedItemColor: colorScheme.primary,

        unselectedItemColor:
            colorScheme.onSurface.withOpacity(0.6),

        onTap: (index) {
  _navigateToTab(context, index);
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
      ),
    );
  }
}