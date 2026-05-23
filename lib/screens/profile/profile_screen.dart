import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/shops_provider.dart';

import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';

import '../properties/add_property_screen.dart';
import '../properties/my_properties_screen.dart';
import '../payments/payment_history_screen.dart';
import '../wallet/wallet_transactions_screen.dart';
import '../delivery/seller_delivery_screen.dart';
import '../events/manage_events_screen.dart';

import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../orders/orders_screen.dart';
import '../auth/login_screen.dart';
import '../products/add_product_screen.dart';
import '../shops/create_shop_screen.dart';
import '../shops/my_shop_screen.dart';
import '../events/my_tickets_screen.dart';
import '../hospitality/lodge_owner_dashboard.dart';

import '../../utils/user_role_utils.dart';
import '../../theme/design_system/app_spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;



    final walletAsync = ref.watch(walletProvider);
    final username = user?.username;

    // ✅ SAFE ROLE CHECK
    final isLoggedIn = authState.isAuthenticated;
    final isShopOwner = user?.userType == "shop_owner";


    final isHospitalityOwner = user?.userType == 'hospitality_owner';

    // ⚠️ IMPORTANT: ensure fallback false if null
    //final hasShop = ref.watch(hasShopProvider) == true;
    final hasShop = ref.watch(hasShopProvider);
    //final hasShopAsync = ref.watch(hasShopProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

      appBar: MainAppBar(
        title: username ?? 'Profile',
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 45),

            // ================= HEADER =================
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: EdgeInsets.all(AppSpacing.md),
                  padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.mangoOrange,
                        AppColors.leafGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Text(
                        user?.firstName ?? "User Name",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.email ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                          ),
                        decoration: BoxDecoration(
                          color: UserRoleUtils.getColor(user?.userType ?? ''),
                          borderRadius: BorderRadius.circular(20),
                          ),
                        child: Text(
                          UserRoleUtils.getLabel(user?.userType ?? ''),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      walletAsync.when(
                        data: (wallet) => Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _stat(context, "Balance",
                                "${wallet.currency} ${wallet.balance}"),
                            _stat(context, "Earnings",
                                "${wallet.currency} ${wallet.totalEarnings}"),
                            _stat(context, "Withdrawn",
                                "${wallet.currency} ${wallet.totalWithdrawn}"),
                          ],
                        ),
                        loading: () =>
                            CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        error: (_, __) =>
                            Text("Wallet error"),
                      ),
                    ],
                  ),
                ),

                const Positioned(
                  top: -35,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.mangoOrange,
                    child: Icon(Icons.person,
                        size: 40, color: Theme.of(context).colorScheme.surface),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= MENU =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [

                  _menuTile(
                    context,
                    Icons.shopping_bag,
                    "My Orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    context,
                    Icons.payment,
                    "My Payments",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PaymentHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    context,
                    Icons.confirmation_number,
                    "My Tickets",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyTicketsScreen(),
                          ),
                        );
                      },
                  ),

                  if (isLoggedIn && isHospitalityOwner)
                  _menuTile(
                    context,
                    Icons.dashboard,
                    "Lodge Dashboard",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LodgeOwnerDashboard(),
                          ),
                        );
                      },
                      ),

                  _menuTile(
                    context,
                    Icons.home_work,
                    "My Properties",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MyPropertiesScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    context,
                    Icons.account_balance_wallet,
                    "Wallet Transactions",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const WalletTransactionsScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    context,
                    Icons.event,
                    "Manage Events",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageEventsScreen(),
                          ),
                        );
                      },
                      ),



                  // ================= SHOP SECTION =================

// ================= SHOP SECTION =================

if (isLoggedIn && isShopOwner && !hasShop)
  _menuTile(
    context,
    Icons.add_business,
    "Create Shop",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreateShopScreen(),
        ),
      );
    },
  ),

if (isLoggedIn && isShopOwner && hasShop) ...[
  _menuTile(
    context,
    Icons.store,
    "My Shop",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyShopScreen(),
        ),
      );
    },
  ),

  _menuTile(
    context,
    Icons.local_shipping,
    "Manage Deliveries",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SellerDeliveryScreen(),
        ),
      );
    },
  ),

  _menuTile(
    context,
    Icons.add_box,
    "Add Product",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddProductScreen(),
        ),
      );
    },
  ),
],

        

        
                  _menuTile(
                    context,
                    Icons.settings,
                    "Settings",
                  ),

                  _menuTile(
                    context,
                    Icons.logout,
                    "Logout",
                    onTap: () async {
                      await ref
                          .read(authProvider.notifier)
                          .logout();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= WALLET STAT =================
  Widget _stat(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ================= MENU TILE =================
  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.mangoOrange),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap ?? () {},
      ),
    );
  }
}
