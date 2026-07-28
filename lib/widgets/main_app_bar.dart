// lib/widgets/main_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../theme/design_system/app_spacing.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart'; 
import '../screens/search/unified_search_screen.dart'; 
import '../services/analytics_service.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap; 
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final Widget? title; 
  final Widget? leading;

  static final AnalyticsService _analyticsService = AnalyticsService();

  const MainAppBar({
    super.key,
    this.title, 
    this.onProfileTap, 
    this.onSearchTap,
    this.onCartTap, 
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return AppBar(
      centerTitle: false,
      titleSpacing: 4.0, 
      automaticallyImplyLeading: leading == null ? !isDesktop : false,
      leading: leading,
      
      title: Align(
        alignment: Alignment.centerLeft,
        child: title ??
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              fit: BoxFit.contain,
            ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search Platform',
          onPressed: () {
            _analyticsService.logEvent('appbar_search_click');
            if (onSearchTap != null) {
              onSearchTap!();
            }
          },
        ),

        // CART BUTTON WITH BADGE
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                _analyticsService.logEvent('appbar_cart_click');
                if (onCartTap != null) {
                  onCartTap!();
                }
              },
              tooltip: 'Shopping Cart',
            ),
            if (cartItems.isNotEmpty)
              Positioned(
                right: 4,
                top: 4,
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
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),

        // AUTHENTICATION / PROFILE BUTTONS
        if (isDesktop) ...[
          if (!isLoggedIn) ...[
            TextButton(
              onPressed: () => _handleAuthNavigation(context, 'login'),
              child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => _handleAuthNavigation(context, 'register'),
              child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            TextButton.icon(
              icon: const Icon(Icons.account_circle, size: 22),
              label: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () => _handleAuthNavigation(context, 'profile'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => _handleAuthNavigation(context, 'logout', ref: ref),
              child: const Text('Logout'),
            ),
          ],
        ] else ...[
          // 👈 MOBILE AUTH POPUP MENU BUTTON
          PopupMenuButton<String>(
            offset: const Offset(0, 45), // Drops menu right below the button
            onSelected: (value) => _handleAuthNavigation(context, value, ref: ref),
            
            // 👈 If logged out: Shows explicit "Login" text button with icon instead of three dots
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: isLoggedIn
                  ? const Icon(Icons.account_circle, size: 28)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            itemBuilder: (_) {
              if (!isLoggedIn) {
                return const [
                  PopupMenuItem(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(Icons.login, size: 18),
                        SizedBox(width: 8),
                        Text('Login'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'register',
                    child: Row(
                      children: [
                        Icon(Icons.person_add_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Register'),
                      ],
                    ),
                  ),
                ];
              }
              return const [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  void _handleAuthNavigation(BuildContext context, String destination, {WidgetRef? ref}) async {
    _analyticsService.logEvent('appbar_${destination}_click');

    switch (destination) {
      case 'login':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        break;
      case 'register':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
        break;
      case 'profile':
        if (onProfileTap != null) onProfileTap!();
        break;
      case 'logout':
        if (ref != null) {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}