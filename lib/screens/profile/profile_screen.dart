import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/shops_provider.dart';

import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/app_scaffold.dart';

import '../properties/my_properties_screen.dart';
import '../payments/payment_history_screen.dart';
import '../wallet/wallet_transactions_screen.dart';
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

  void _toggle(String key) {
    setState(() {
      _expanded[key] = !(_expanded[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final walletAsync = ref.watch(walletProvider);
    final hasShop = ref.watch(hasShopProvider);

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 360 ? 1 : 2;

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: MainAppBar(
        title: user?.username ?? 'Profile',
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 35),

            // ================= HEADER =================
            Container(
              margin: EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.mangoOrange,
                    AppColors.leafGreen,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "${user?.firstName ?? ""} ${user?.lastName ?? ""}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    user?.email ?? "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 10),

                  walletAsync.when(
                    data: (wallet) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _miniStat("Bal", "${wallet.currency} ${wallet.balance}"),
                        _miniStat("Earn", "${wallet.currency} ${wallet.totalEarnings}"),
                        _miniStat("Out", "${wallet.currency} ${wallet.totalWithdrawn}"),
                      ],
                    ),
                    loading: () =>
                        const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => const Text("Wallet error"),
                  ),
                ],
              ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const WalletTransactionsScreen(),
                          ),
                        );
                      }),
                      _gridCard(Icons.payment, "Payments", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentHistoryScreen(),
                          ),
                        );
                      }),
                    ],
                  ),

                  _sectionCard(
                    key: "activity",
                    title: "My Activity",
                    crossAxisCount: crossAxisCount,
                    children: [
                      _gridCard(Icons.shopping_bag, "Orders", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrdersScreen(),
                          ),
                        );
                      }),
                      _gridCard(Icons.hotel, "Bookings", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsScreen(),
                          ),
                        );
                      }),
                      _gridCard(Icons.confirmation_number, "Tickets", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyTicketsScreen(),
                          ),
                        );
                      }),
                    ],
                  ),

                  _sectionCard(
                    key: "management",
                    title: "Management",
                    crossAxisCount: crossAxisCount,
                    children: [
                      _gridCard(Icons.dashboard, "Lodge", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LodgeOwnerDashboard(),
                          ),
                        );
                      }),
                      _gridCard(Icons.home_work, "Properties", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyPropertiesScreen(),
                          ),
                        );
                      }),
                      _gridCard(Icons.event, "Events", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageEventsScreen(),
                          ),
                        );
                      }),
                    ],
                  ),

                  _sectionCard(
                    key: "shop",
                    title: "Shop Management",
                    crossAxisCount: crossAxisCount,
                    children: !hasShop
                        ? [
                            _gridCard(Icons.add_business, "Create Shop", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CreateShopScreen(),
                                ),
                              );
                            }),
                          ]
                        : [
                            _gridCard(Icons.store, "My Shop", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyShopScreen(),
                                ),
                              );
                            }),
                            _gridCard(Icons.add_box, "Add Product", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddProductScreen(),
                                ),
                              );
                            }),
                            _gridCard(Icons.local_shipping, "Deliveries", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SellerDeliveryScreen(),
                                ),
                              );
                            }),
                          ],
                  ),

                  _sectionCard(
                    key: "account",
                    title: "Account",
                    crossAxisCount: crossAxisCount,
                    children: [
                      _gridCard(Icons.settings, "Settings", () {}),
                      _gridCard(Icons.logout, "Logout", () async {
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
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= SECTION CARD =================
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
          InkWell(
            onTap: () => _toggle(key),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
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

  // ================= GRID CARD =================
  Widget _gridCard(
      IconData icon, String title, VoidCallback onTap) {
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

  // ================= MINI STAT =================
  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}