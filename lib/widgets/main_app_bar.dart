import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';

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
      titleSpacing: 0,
      title: Text(title),

      actions: [
        // 🛒 CART
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
              },
            ),

            if (cartItems.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
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
                      fontSize: 10,
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
}