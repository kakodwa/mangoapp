// lib/screens/profile/profile_screen.dart

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

import '../main_tabs_screen.dart';

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
import '../../widgets/web_footer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // 🌟 Expanded "shop" section first by default
  final Map<String, bool> _expanded = {
    "shop": true,
    "payments": false,
    "activity": false,
    "management": false,
    "account": false,
  };
  
  bool _hasLoggedView = false;

  void _toggle(String key) {
    setState(() {
      final isCurrentlyOpen = _expanded[key] ?? false;
      _expanded.updateAll((k, v) => false);
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
    
    // Responsive grid distribution based on platform width
    int crossAxisCount = 2;
    if (width >= 1024) {
      crossAxisCount = 4; 
    } else if (width >= 600) {
      crossAxisCount = 3; 
    } else if (width < 340) {
      crossAxisCount = 1; 
    }
    
    final AnalyticsService analytics = AnalyticsService();

    if (isLoggedIn && !_hasLoggedView && user != null) {
      analytics.logEvent('profile_hub_view');
      _hasLoggedView = true;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // ================= CENTERED & CONSTRAINED MAIN CONTENT =================
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 850),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // ================= HEADER =================
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(AppSpacing.md),
                        padding: const EdgeInsets.fromLTRB(24, 65, 24, 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mangoOrange, AppColors.leafGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${user?.firstName ?? ""} ${user?.lastName ?? ""}".trim().isEmpty 
                                  ? "User Account" 
                                  : "${user?.firstName ?? ""} ${user?.lastName ?? ""}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            walletAsync.when(
                              data: (wallet) => Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _miniStat("Balance", "${wallet.currency} ${wallet.balance.toStringAsFixed(2)}"),
                                  _miniStat("Escrow", "${wallet.currency} ${wallet.escrowBalance.toStringAsFixed(2)}"),
                                  _miniStat("Earnings", "${wallet.currency} ${wallet.totalEarnings.toStringAsFixed(2)}"),
                                  _miniStat("Withdrawn", "${wallet.currency} ${wallet.totalWithdrawn.toStringAsFixed(2)}"),
                                ],
                              ),
                              loading: () => const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              error: (_, __) => const Text(
                                "Wallet data error",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: -35,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 41,
                            backgroundColor: AppColors.mangoOrange,
                            child: Icon(Icons.person, size: 45, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ================= MENU =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // 1. SHOP MANAGEMENT TAB (FIRST)
                        if (isLoggedIn)
                          _sectionCard(
                            key: "shop",
                            title: "Shop Management",
                            descriptionEn: "Create and manage your online shop, upload products, and track customer orders.",
                            descriptionNy: "Tsegulani ndi kusamalira shop yanu, ikani katundu, komanso onani zooda za makasitomala anu.",
                            crossAxisCount: crossAxisCount,
                            children: !hasShop
                                ? [
                                    _gridCard(
                                      Icons.add_business_outlined, 
                                      "Create Shop", 
                                      () {
                                        analytics.logEvent('profile_click_create_shop');
                                        MainTabsScreen.of(context)?.navigateToCreateShop();
                                      },
                                    ),
                                  ]
                                : [
                                    _gridCard(
                                      Icons.store_outlined, 
                                      "My Shop", 
                                      () {
                                        analytics.logEvent('profile_click_my_shop');
                                        MainTabsScreen.of(context)?.navigateToMyShop();
                                      },
                                    ),
                                    _gridCard(
                                      Icons.add_box_outlined, 
                                      "Add Product", 
                                      () {
                                        analytics.logEvent('profile_click_add_product');
                                        MainTabsScreen.of(context)?.navigateToAddProduct();
                                      },
                                    ),
                                    _gridCard(
                                      Icons.local_shipping_outlined, 
                                      "Deliveries & Orders", 
                                      () {
                                        analytics.logEvent('profile_click_deliveries');
                                        MainTabsScreen.of(context)?.navigateToSellerDeliveries();
                                      },
                                    ),
                                  ],
                          ),

                        // 2. PAYMENTS & WALLET TAB
                        _sectionCard(
                          key: "payments",
                          title: "Payments & Wallet",
                          descriptionEn: "View your wallet balance, check payment history, request cashouts, and view payout records.",
                          descriptionNy: "Onani ndalama zanu zotsala, mbiri yolipira, tulutsani ndalama zanu, komanso mbiri yazotulutsidwa.",
                          crossAxisCount: crossAxisCount,
                          children: [
                            _gridCard(
                              Icons.account_balance_wallet_outlined, 
                              "Wallet", 
                              () {
                                analytics.logEvent('profile_click_wallet');
                                MainTabsScreen.of(context)?.navigateToWalletTransactions();
                              },
                            ),
                            _gridCard(
                              Icons.payment_outlined, 
                              "Payments", 
                              () {
                                analytics.logEvent('profile_click_payment_history');
                                MainTabsScreen.of(context)?.navigateToPaymentHistory();
                              },
                            ),
                            _gridCard(
                              Icons.outbox_outlined, 
                              "Withdraw Money", 
                              () {
                                analytics.logEvent('profile_click_withdraw_request');
                                MainTabsScreen.of(context)?.navigateToWithdrawal();
                              },
                            ),
                            _gridCard(
                              Icons.history_outlined, 
                              "Cashout History", 
                              () {
                                analytics.logEvent('profile_click_payout_history');
                                MainTabsScreen.of(context)?.navigateToPayoutHistory();
                              },
                            ),
                          ],
                        ),

                        // 3. MY ACTIVITY TAB
                        _sectionCard(
                          key: "activity",
                          title: "My Activity",
                          descriptionEn: "Track your personal orders, lodge bookings, event tickets, and unlocked properties.",
                          descriptionNy: "Onani katundu amene mwagula, booked lodge, matikiti amisonkhano, ndi malo ogulidwa.",
                          crossAxisCount: crossAxisCount,
                          children: [
                            _gridCard(
                              Icons.shopping_bag_outlined, 
                              "Orders", 
                              () {
                                analytics.logEvent('profile_click_orders');
                                MainTabsScreen.of(context)?.navigateToOrders();
                              },
                            ),
                            _gridCard(
                              Icons.hotel_outlined, 
                              "Bookings", 
                              () {
                                analytics.logEvent('profile_click_bookings');
                                MainTabsScreen.of(context)?.navigateToMyBookings();
                              },
                            ),
                            _gridCard(
                              Icons.confirmation_number_outlined, 
                              "Tickets", 
                              () {
                                analytics.logEvent('profile_click_tickets');
                                MainTabsScreen.of(context)?.navigateToMyTickets();
                              },
                            ),
                            _gridCard(
                              Icons.lock_open_outlined, 
                              "Unlocked Properties", 
                              () {
                                analytics.logEvent('profile_click_unlocked_properties');
                                MainTabsScreen.of(context)?.navigateToMyUnlockedProperties();
                              },
                            ),
                          ],
                        ),

                        // 4. MANAGEMENT TAB
                        _sectionCard(
                          key: "management",
                          title: "Lodge, Properties & Events Management ",
                          descriptionEn: "Manage your listed lodges, real estate properties, and organized event shows.",
                          descriptionNy: "Yendetsani malo ogona (lodge), nyumba kapena malo ogulitsa, ndi misonkhano kapena zochitika zanu.",
                          crossAxisCount: crossAxisCount,
                          children: [
                            _gridCard(
                              Icons.dashboard_outlined, 
                              "Lodge", 
                              () {
                                analytics.logEvent('profile_click_lodge_dashboard');
                                MainTabsScreen.of(context)?.navigateToLodgeDashboard();
                              },
                            ),
                            _gridCard(
                              Icons.home_work_outlined, 
                              "Properties", 
                              () {
                                analytics.logEvent('profile_click_properties');
                                MainTabsScreen.of(context)?.navigateToMyProperties();
                              },
                            ),
                            _gridCard(
                              Icons.event_outlined, 
                              "Events", 
                              () {
                                analytics.logEvent('profile_click_manage_events');
                                MainTabsScreen.of(context)?.navigateToManageEvents();
                              },
                            ),
                          ],
                        ),

                        // 5. ACCOUNT TAB
                        _sectionCard(
                          key: "account",
                          title: "Account",
                          descriptionEn: "Adjust app settings or safely sign out from your user account.",
                          descriptionNy: "Konzani zinthu zina za account yanu kapena tulukani bwinobwino mu account yanu.",
                          crossAxisCount: crossAxisCount,
                          children: [
                            _gridCard(
                              Icons.settings_outlined, 
                              "Settings", 
                              () {
                                analytics.logEvent('profile_click_settings');
                              },
                            ),
                            _gridCard(
                              Icons.logout_rounded, 
                              "Logout", 
                              () async {
                                analytics.logEvent('profile_explicit_logout');
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),

          // Web/Desktop Footer
          const WebFooter(),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String key,
    required String title,
    required String descriptionEn,
    required String descriptionNy,
    required List<Widget> children,
    required int crossAxisCount,
  }) {
    final isOpen = _expanded[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
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
            firstChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🌟 EXPANDED HEADER DESCRIPTION BANNER (ENGLISH + CHICHEWA)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.mangoOrange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.mangoOrange.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          descriptionEn,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          descriptionNy,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: children,
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
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
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.mangoOrange),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF343A40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
          ),
        ],
      ),
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
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(16),
        bottom: Radius.circular(isOpen ? 0 : 16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            Icon(
              isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}