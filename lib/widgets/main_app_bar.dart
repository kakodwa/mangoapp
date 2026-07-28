import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_tabs_screen.dart';
import '../services/analytics_service.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onDeliveryTap;
  final Widget? title;
  final Widget? leading;

  static final AnalyticsService _analyticsService = AnalyticsService();

  const MainAppBar({
    super.key,
    this.title,
    this.onProfileTap,
    this.onSearchTap,
    this.onCartTap,
    this.onDeliveryTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppBar(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              automaticallyImplyLeading: leading == null ? !isDesktop : false,
              leading: leading,
              title: title ??
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
              actions: [
                // Desktop Header Navigation Links
                if (isDesktop) ...[
                  TextButton(
                    onPressed: () => MainTabsScreen.of(context)?.setSelectedIndex(0),
                    child: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () => MainTabsScreen.of(context)?.setSelectedIndex(1),
                    child: const Text('Shops', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () => MainTabsScreen.of(context)?.setSelectedIndex(2),
                    child: const Text('Products', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () {
                      _analyticsService.logEvent('appbar_delivery_click');
                      if (onDeliveryTap != null) {
                        onDeliveryTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(9); // Delivery Code Screen
                      }
                    },
                    child: const Text('Confirm Delivery', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () {
                      _analyticsService.logEvent('appbar_help_click');
                      MainTabsScreen.of(context)?.setSelectedIndex(11); // Help Screen
                    },
                    child: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),

                  // Header Desktop Search Bar
                  Container(
                    width: 240,
                    height: 38,
                    margin: const EdgeInsets.only(right: 12),
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        _analyticsService.logEvent('appbar_search_click');
                        onSearchTap?.call();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search platform...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Search Platform',
                    onPressed: () {
                      _analyticsService.logEvent('appbar_search_click');
                      onSearchTap?.call();
                    },
                  ),
                ],

                // Shopping Cart Button
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        _analyticsService.logEvent('appbar_cart_click');
                        onCartTap?.call();
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
                const SizedBox(width: 8),

                // Auth Action Buttons
                if (isDesktop) ...[
                  if (!isLoggedIn) ...[
                    TextButton(
                      onPressed: () => _handleAuthNavigation(context, 'login'),
                      child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    const SizedBox(width: 4),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _handleAuthNavigation(context, 'logout', ref: ref),
                      child: const Text('Logout'),
                    ),
                  ],
                ] else ...[
                  PopupMenuButton<String>(
                    offset: const Offset(0, 45),
                    onSelected: (value) => _handleAuthNavigation(context, value, ref: ref),
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
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      size: 16, color: Theme.of(context).colorScheme.primary),
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
                    itemBuilder: (_) => !isLoggedIn
                        ? const [
                            PopupMenuItem(value: 'login', child: Text('Login')),
                            PopupMenuItem(value: 'register', child: Text('Register')),
                          ]
                        : const [
                            PopupMenuItem(value: 'profile', child: Text('Profile')),
                            PopupMenuItem(value: 'logout', child: Text('Logout')),
                          ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
        onProfileTap?.call();
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