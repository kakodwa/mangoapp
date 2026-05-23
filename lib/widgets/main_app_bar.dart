import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
<<<<<<< HEAD
import '../theme/design_system/app_spacing.dart';
=======

>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import '../screens/cart/cart_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/login_screen.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    return AppBar(
      centerTitle: false,
<<<<<<< HEAD
      titleSpacing: AppSpacing.md,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // CART BUTTON
=======
      titleSpacing: 0,
      title: Text(title),

      actions: [
        // 🛒 CART
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
<<<<<<< HEAD
              icon: const Icon(Icons.shopping_cart_outlined),
=======
              icon: const Icon(Icons.shopping_cart),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
              },
<<<<<<< HEAD
              tooltip: 'Shopping Cart',
            ),
            if (cartItems.isNotEmpty)
              Positioned(
                right: 4,
                top: 4,
=======
            ),

            if (cartItems.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cartItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
<<<<<<< HEAD
                      fontSize: 9,
=======
                      fontSize: 10,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // 👤 AUTH MENU ONLY
        PopupMenuButton<String>(
          icon: const Icon(Icons.person),

          onSelected: (value) async {
            if (value == 'login') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            }

            if (value == 'profile') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            }

            if (value == 'logout') {
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            }
          },

          itemBuilder: (_) {
            // 🚫 NOT LOGGED IN
            if (!isLoggedIn) {
              return const [
                PopupMenuItem(
                  value: 'login',
                  child: Text('Login'),
                ),
              ];
            }

            // ✅ LOGGED IN
            return const [
              PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
<<<<<<< HEAD
}
=======
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
