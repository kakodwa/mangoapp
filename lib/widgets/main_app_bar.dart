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
  final String title;
  final Widget? leading; // 👈 ADDED: Explicit property to inject dynamic back buttons

  static final AnalyticsService _analyticsService = AnalyticsService();

  const MainAppBar({
    super.key,
    required this.title,
    this.onProfileTap, 
    this.onSearchTap,
    this.onCartTap, 
    this.leading, // 👈 ADDED to constructor
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
      titleSpacing: isDesktop ? AppSpacing.xl : AppSpacing.md,
      // 👈 MODIFIED: Show drawer toggle ONLY on mobile AND when no custom leading widget (like our back button) is passed
      automaticallyImplyLeading: leading == null ? !isDesktop : false,
      leading: leading, // 👈 ADDED: Binds our custom back button action directly to the AppBar layout
      title: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo/Title Brand Layer
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Colors.orange,       
                    Colors.deepOrange,   
                    Colors.green,        
                  ],
                  stops: [0.0, 0.6, 1.0], 
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  title,
                  style: (isDesktop 
                      ? Theme.of(context).textTheme.headlineSmall 
                      : Theme.of(context).textTheme.titleLarge)?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white, 
                      ),
                ),
              ),

              // Actions Utility Panel
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔍 GLOBAL UNIFIED SEARCH BUTTON
                  //const InstallAppButton(),
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
                  const SizedBox(width: 8),

                  // 🔘 ADAPTIVE AUTH WEB DIRECT LINK ENTRIES / DROP-DOWN ACTIONS
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
                    // Standard fallback icons interface menu block for phone form factors
                    PopupMenuButton<String>(
                      icon: Icon(
                        isLoggedIn ? Icons.account_circle : Icons.more_vert,
                        size: isLoggedIn ? 28.0 : null,
                      ),
                      onSelected: (value) => _handleAuthNavigation(context, value, ref: ref),
                      itemBuilder: (_) {
                        if (!isLoggedIn) {
                          return const [
                            PopupMenuItem(value: 'login', child: Text('Login')),
                            PopupMenuItem(value: 'register', child: Text('Register')),
                          ];
                        }
                        return const [
                          PopupMenuItem(value: 'profile', child: Text('Profile')),
                          PopupMenuDivider(),
                          PopupMenuItem(value: 'logout', child: Text('Logout')),
                        ];
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Unified controller to process auth clicks natively across both view modes
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