import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/shops_provider.dart';

import '../../theme/app_colors.dart';

import '../properties/my_properties_screen.dart';
import '../properties/my_unlocked_properties_screen.dart';
import '../payments/payment_history_screen.dart';
import '../wallet/wallet_transactions_screen.dart';
import '../wallet/withdrawal_screen.dart';
import '../wallet/payout_history_screen.dart';
import '../delivery/seller_delivery_screen.dart';
import '../events/manage_events_screen.dart';

import '../orders/orders_screen.dart';
import '../auth/login_screen.dart';

import '../products/add_product_screen.dart';
import '../shops/create_shop_screen.dart';
import '../shops/my_shop_screen.dart';

import '../events/my_tickets_screen.dart';
import '../hospitality/lodge_owner_dashboard.dart';
import '../hospitality/my_bookings_screen.dart';

import '../../theme/design_system/app_spacing.dart';
import '../../services/analytics_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final Map<String, bool> _expanded = {
    "payments": true,
    "activity": false,
    "management": false,
    "shop": false,
    "account": false,
  };
  
  bool _hasLoggedView = false;

  // Modified toggle method to close other panels when one opens
  void _toggle(String key) {
    setState(() {
      final isCurrentlyOpen = _expanded[key] ?? false;
      
      // Close all panels
      _expanded.updateAll((k, v) => false);
      
      // Toggle the targeted panel based on its previous state
      _expanded[key] = !isCurrentlyOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoggedIn = authState.isAuthenticated;
    final walletAsync = ref.watch(walletProvider);
    final hasShop = ref.watch(hasShopProvider);

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 360 ? 1 : 2;
    
    final AnalyticsService analytics = AnalyticsService();

    if (isLoggedIn && !_hasLoggedView && user != null) {
      analytics.logEvent('profile_hub_view');
      _hasLoggedView = true;
    }

    return SingleChildScrollView(
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
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.mangoOrange, AppColors.leafGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "${user?.firstName ?? ""} ${user?.lastName ?? ""}",
                      style: const TextStyle(
                        color: Colors.white,
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
                    const SizedBox(height: 20),
                    walletAsync.when(
                      data: (wallet) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _miniStat("Balance", "${wallet.currency} ${wallet.balance}"),
                          _miniStat("Earnings", "${wallet.currency} ${wallet.totalEarnings}"),
                          _miniStat("Withdrawn", "${wallet.currency} ${wallet.totalWithdrawn}"),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(color: Colors.white),
                      error: (_, __) => const Text("Wallet error"),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: -35,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.mangoOrange,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // ================= MENU =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _sectionCard(
                  key: "payments",
                  title: "Payments & Wallet",
                  crossAxisCount: crossAxisCount,
                  children: [
                    _gridCard(Icons.account_balance_wallet, "Wallet", () {
                      analytics.logEvent('profile_click_wallet');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletTransactionsScreen()));
                    }),
                    _gridCard(Icons.payment, "Payments", () {
                      analytics.logEvent('profile_click_payment_history');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()));
                    }),
                    _gridCard(Icons.outbox, "Withdraw Money", () {
                      analytics.logEvent('profile_click_withdraw_request');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalScreen()));
                    }),
                    _gridCard(Icons.history, "Cashout History", () {
                      analytics.logEvent('profile_click_payout_history');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PayoutHistoryScreen()));
                    }),
                  ],
                ),

                _sectionCard(
                  key: "activity",
                  title: "My Activity",
                  crossAxisCount: crossAxisCount,
                  children: [
                    _gridCard(Icons.shopping_bag, "Orders", () {
                      analytics.logEvent('profile_click_orders');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                    }),
                    _gridCard(Icons.hotel, "Bookings", () {
                      analytics.logEvent('profile_click_bookings');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                    }),
                    _gridCard(Icons.confirmation_number, "Tickets", () {
                      analytics.logEvent('profile_click_tickets');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTicketsScreen()));
                    }),
                    _gridCard(Icons.no_encryption, "Unlocked Properties", () {
                      analytics.logEvent('profile_click_unlocked_properties');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyUnlockedPropertiesScreen()));
                    }),
                  ],
                ),

                _sectionCard(
                  key: "management",
                  title: "Management",
                  crossAxisCount: crossAxisCount,
                  children: [
                    _gridCard(Icons.dashboard, "Lodge", () {
                      analytics.logEvent('profile_click_lodge_dashboard');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LodgeOwnerDashboard()));
                    }),
                    _gridCard(Icons.home_work, "Properties", () {
                      analytics.logEvent('profile_click_properties');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPropertiesScreen()));
                    }),
                    _gridCard(Icons.event, "Events", () {
                      analytics.logEvent('profile_click_manage_events');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventsScreen()));
                    }),
                  ],
                ),

                if (isLoggedIn)
                  _sectionCard(
                    key: "shop",
                    title: "Shop Management",
                    crossAxisCount: crossAxisCount,
                    children: !hasShop
                        ? [
                            _gridCard(Icons.add_business, "Create Shop", () {
                              analytics.logEvent('profile_click_create_shop');
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateShopScreen()));
                            }),
                          ]
                        : [
                            _gridCard(Icons.store, "My Shop", () {
                              analytics.logEvent('profile_click_my_shop');
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyShopScreen()));
                            }),
                            _gridCard(Icons.add_box, "Add Product", () {
                              analytics.logEvent('profile_click_add_product');
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                            }),
                            _gridCard(Icons.local_shipping, "Deliveries", () {
                              analytics.logEvent('profile_click_deliveries');
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerDeliveryScreen()));
                            }),
                          ],
                  ),

                _sectionCard(
                  key: "account",
                  title: "Account",
                  crossAxisCount: crossAxisCount,
                  children: [
                    _gridCard(Icons.settings, "Settings", () {
                      analytics.logEvent('profile_click_settings');
                    }),
                    _gridCard(Icons.logout, "Logout", () async {
                      analytics.logEvent('profile_explicit_logout');
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String key,
    required String title,
    required List<Widget> children,
    required int crossAxisCount,
  }) {
    final isOpen = _expanded[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          MakeActionInkWell(
            keyName: key,
            title: title,
            isOpen: isOpen,
            onTap: () => _toggle(key),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.6,
                children: children,
              ),
            ),
            secondChild: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _gridCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.mangoOrange),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class MakeActionInkWell extends StatelessWidget {
  final String keyName;
  final String title;
  final bool isOpen;
  final VoidCallback onTap;

  const MakeActionInkWell({
    super.key,
    required this.keyName,
    required this.title,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}