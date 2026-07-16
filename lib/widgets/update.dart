import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import '../providers/auth_provider.dart';
import '../providers/shops_provider.dart'; 
import '../screens/auth/register_screen.dart'; 
import '../screens/products/add_product_screen.dart'; 
import '../screens/shops/create_shop_screen.dart'; 
import '../screens/main_tabs_screen.dart';


class UpdatesTicker extends ConsumerWidget {
  const UpdatesTicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the authentication state
    final authState = ref.watch(authProvider); //[cite: 4]
    final isAuthenticated = authState.isAuthenticated; //[cite: 4]

    // 2. Watch whether the authenticated user has a shop
    final hasShop = ref.watch(hasShopProvider); //[cite: 4]

    // Determine marquee text based on authentication and shop status
    String tickerText = '🛍️ Find amazing local products with secure checkout •  🚚 Fast delivery straight to your doorstep •';
    
    if (!isAuthenticated) {
      tickerText += '  🚀 Create an account to start listing, shopping, and tracking your orders! •'; //[cite: 1]
    } else if (!hasShop) {
      tickerText += '  🏬 Create a shop today to start listing your products and reaching customers! •';
    } else {
      tickerText += '  🚀 Start listing your products to reach more customers today! •';
    }

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          const Icon(
            Icons.campaign,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Marquee(
              text: tickerText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              scrollAxis: Axis.horizontal,
              blankSpace: 100,
              velocity: 40,
              pauseAfterRound: const Duration(seconds: 1),
            ),
          ),
          const SizedBox(width: 8),
          
          // Dynamic Button depending on Auth & Shop existence
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: Icon(
              !isAuthenticated 
                  ? Icons.person_add_alt_1 
                  : (hasShop ? Icons.add_box_outlined : Icons.add_business_outlined), //[cite: 4]
              size: 14,
            ),
            label: Text(
              !isAuthenticated 
                  ? "Join" //[cite: 1]
                  : (hasShop ? "List products" : "Create Shop"), //[cite: 4]
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (!isAuthenticated) {
                // Not authenticated -> Register Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()), //[cite: 1]
                );
              } else if (!hasShop) {
                // Authenticated but has no shop -> Create Shop Screen
                MainTabsScreen.of(context)?.navigateToCreateShop();
              } else {
                // Authenticated and has shop -> Add Product Screen
                MainTabsScreen.of(context)?.navigateToAddProduct();
              }
            },
          ),
        ],
      ),
    );
  }
}