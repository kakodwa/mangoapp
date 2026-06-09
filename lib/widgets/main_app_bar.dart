import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../theme/design_system/app_spacing.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/auth/login_screen.dart';
// Imported RegisterScreen (Adjust path to match your exact directory structure)
import '../screens/auth/register_screen.dart'; 
import '../screens/search/unified_search_screen.dart'; 
// Import your Analytics Service (Adjust this path matching your actual directory structure)
import '../services/analytics_service.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap; 
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final String title;

  // Static final instance allows us to keep the 'const' constructor intact
  static final AnalyticsService _analyticsService = AnalyticsService();

  const MainAppBar({
    super.key,
    required this.title,
    this.onProfileTap, 
    this.onSearchTap,
    this.onCartTap, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    return AppBar(
      centerTitle: false,
      titleSpacing: AppSpacing.md,
      title: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Colors.orange,       // Orange dominates
            Colors.deepOrange,   // Smooth transition
            Colors.green,        // Ends in green
          ],
          stops: [0.0, 0.6, 1.0], // 70% of the text stays orange/deepOrange before switching to green
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white, // Required placeholder color for ShaderMask to overlay on
              ),
        ),
      ),
      actions: [
        // 🔍 GLOBAL UNIFIED SEARCH BUTTON
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

        // CART BUTTON
        Stack(
          clipBehavior: Clip.none,
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

        // 🔘 DYNAMIC AUTH MENU 
        PopupMenuButton<String>(
          icon: Icon(
            isLoggedIn ? Icons.account_circle : Icons.more_vert,
            size: isLoggedIn ? 28.0 : null,
          ),
          onSelected: (value) async {
            if (value == 'login') {
              _analyticsService.logEvent('appbar_login_click');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            }

            if (value == 'register') {
              _analyticsService.logEvent('appbar_register_click');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            }

            if (value == 'profile') {
              _analyticsService.logEvent('appbar_profile_click');

              if (onProfileTap != null) {
                onProfileTap!();
              }
            }

            if (value == 'logout') {
              _analyticsService.logEvent('appbar_logout_click');
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
            if (!isLoggedIn) {
              return const [
                PopupMenuItem(
                  value: 'login',
                  child: Text('Login'),
                ),
                PopupMenuItem(
                  value: 'register',
                  child: Text('Register'),
                ),
              ];
            }

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