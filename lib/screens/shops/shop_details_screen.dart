// lib/screens/shops/shop_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';

import '../../widgets/shop_map_modal.dart';
import '../../widgets/app_fab.dart';
import '../../widgets/reviews/review_section_widget.dart';

import '../auth/login_screen.dart';
import '../products/product_card.dart';
import 'shop_card.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../utils/app_toast.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class ShopDetailsScreen extends ConsumerStatefulWidget {
  final int shopId;

  const ShopDetailsScreen({super.key, required this.shopId});

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  bool _hasLoggedView = false;
  final ScrollController _scrollController = ScrollController();
  
  // Track active tab index (0: Products, 1: About Shop, 2: Contact, 3: Review)
  int _selectedTabIndex = 0;

  void _openWhatsApp(BuildContext context, String phone) async {
    _analytics.logEvent('shop_whatsapp_click');
    final uri = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.info(context, "Could not open WhatsApp");
    }
  }

  void _callPhone(String phone) async {
    _analytics.logEvent('shop_call_click');
    final uri = Uri.parse("tel:$phone");
    await launchUrl(uri);
  }

  void _sendEmail(String email) async {
    _analytics.logEvent('shop_email_click');
    final uri = Uri.parse("mailto:$email");
    await launchUrl(uri);
  }

  // Responsive Grid Count Helper 
  int _getResponsiveCrossAxisCount(double width) {
    if (width < 600) return 2;     // Mobile phones
    if (width < 900) return 3;     // Tablets / Small Screens
    if (width < 1200) return 4;    // Medium Desktop / Large Tablets
    return 5;                      // Wide Desktop monitors
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopDetailsProvider(widget.shopId));
    final productsAsync = ref.watch(productsByShopProvider(widget.shopId));
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isAuthenticated;
    
    // Get the device width for building adaptive views
    final double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 4,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: shopAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
          data: (shop) {
            if (!_hasLoggedView) {
              _analytics.logEvent('shop_view');
              _hasLoggedView = true;
            }

            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // ================= BRAND STOREFRONT BANNER CAROUSEL FRAME
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            shop.banner != null && shop.banner!.isNotEmpty
                                ? Image.network(
                                    shop.banner!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: Colors.grey.shade300),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            // Category Tag
                            Positioned(
                              top: AppSpacing.md,
                              left: AppSpacing.md,
                              child: _GlassTag(text: shop.category),
                            ),
                            // Status Verification Badge
                            Positioned(
                              top: AppSpacing.md,
                              right: AppSpacing.md,
                              child: AppBadge(
                                text: shop.status == 'approved' ? "Verified" : "Pending",
                                type: shop.status == 'approved' ? BadgeType.success : BadgeType.warning,
                              ),
                            ),
                            // Overlay Profile Details Info
                            Positioned(
                              bottom: AppSpacing.md,
                              left: AppSpacing.md,
                              right: AppSpacing.md,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: shop.logo.isNotEmpty ? NetworkImage(shop.logo) : null,
                                      child: shop.logo.isEmpty ? const Icon(Icons.store) : null,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          shop.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              shop.district,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ================= PERFORMANCE METRICS CARD BLOCK
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md, left: AppSpacing.md, right: AppSpacing.md),
                        child: AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(title: "Products", value: "${shop.productCount ?? 0}"),
                              _StatItem(title: "Rating", value: "${shop.rating}"),
                              _StatItem(title: "Reviews", value: "${shop.totalReviews}"),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ================= STICKY TAB BAR
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelColor: AppColors.mangoOrange,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: AppColors.mangoOrange,
                          dividerColor: Colors.transparent,
                          indicatorWeight: 3,
                          onTap: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          tabs: const [
                            Tab(text: "Products"),
                            Tab(text: "About Shop"),
                            Tab(text: "Contact"),
                            Tab(text: "Review"),
                          ],
                        ),
                      ),
                    ),

                    // ================= DYNAMIC TAB CONTENT VIEW MODIFIERS
                    if (_selectedTabIndex == 0) ...[
                      // ================= PRODUCTS LIVE GRID BINDING
                      productsAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                        ),
                        error: (e, _) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Text("Error: $e"))),
                        data: (products) {
                          if (products.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No products available from this vendor."))),
                            );
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: AppSpacing.md),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => ProductCard(product: products[i]),
                                childCount: products.length,
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                // FIXED: Calculating cross-axis item capacity continuously on layout widths
                                crossAxisCount: _getResponsiveCrossAxisCount(screenWidth),
                                childAspectRatio: 0.62,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ] else if (_selectedTabIndex == 1) ...[
                      // ================= DESCRIPTION CONTENT
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "About Store",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                shop.description,
                                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_selectedTabIndex == 2) ...[
                      // ================= INTERACTIVE BUSINESS CONTACT CARD
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Contact Business",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, color: AppColors.mangoOrange),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(shop.phoneNumber)),
                                    IconButton(
                                      icon: const Icon(Icons.call, color: AppColors.leafGreen),
                                      onPressed: () => _callPhone(shop.phoneNumber),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.email, color: AppColors.mangoOrange),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(shop.email)),
                                    IconButton(
                                      icon: const Icon(Icons.send, color: AppColors.leafGreen),
                                      onPressed: () => _sendEmail(shop.email),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.mangoOrange),
                                    const SizedBox(width: 10),
                                    const Expanded(child: Text("WhatsApp Chat")),
                                    IconButton(
                                      icon: const Icon(Icons.message, color: AppColors.leafGreen),
                                      onPressed: () {
                                        if (!isLoggedIn) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          );
                                          return;
                                        }
                                        _openWhatsApp(context, shop.phoneNumber);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else if (_selectedTabIndex == 3) ...[
                      // ================= CUSTOMER REVIEWS SECTION
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: ReviewSectionWidget(
                            targetType: 'shop',
                            targetId: shop.id,
                            isOwner: false,
                          ),
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  ],
                ),

                // ================= UNIFIED FLOATING ACTION SIDE NAVIGATION UTILITY PANEL
                Positioned(
                  bottom: 50,
                  right: 10,
                  child: Column(
                    children: [
                      AppFab(
                        heroTag: "fav_shop",
                        icon: Icons.favorite_border,
                        tooltip: "Favorite Shop",
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppFab(
                        heroTag: "whatsapp_shop_fab",
                        icon: FontAwesomeIcons.whatsapp,
                        tooltip: "WhatsApp Storefront",
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            return;
                          }
                          if (shop.phoneNumber.isEmpty) {
                            AppToast.info(context, "No phone number available");
                            return;
                          }
                          _openWhatsApp(context, shop.phoneNumber);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppFab(
                        heroTag: "share_shop_fab",
                        icon: Icons.share_outlined,
                        tooltip: "Share Shop",
                        onPressed: () async {
                          final String shopUrl = kIsWeb
                              ? "${Uri.base.origin}/shop/${widget.shopId}"
                              : "https://mangobackend-yayy.onrender.com/shop/${widget.shopId}";

                          final String shareMessage = "🏪 *${shop.name}*\n"
                              "📍 Category: ${shop.category}\n\n"
                              "👉 Visit our digital storefront here:\n$shopUrl";

                          _analytics.logEvent('shop_shared_${widget.shopId}');

                          final box = context.findRenderObject() as RenderBox?;
                          await Share.share(
                            shareMessage,
                            subject: 'Check out this shop on Mangochi Market!',
                            sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppFab(
                        heroTag: "map_shop_fab",
                        icon: Icons.map_outlined,
                        tooltip: "Open Map Geolocation",
                        onPressed: () {
                          _analytics.logEvent('shop_map_click');
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => ShopMapModal(
                              shopLat: shop.latitude,
                              shopLng: shop.longitude,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ================= DELEGATE FOR STICKY SLIVER TAB BAR
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overridesParagraphs) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// ================= RENDER STAT METRIC
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isRating = title.toLowerCase() == 'rating';
    final double ratingValue = double.tryParse(value) ?? 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRating)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              if (ratingValue >= starValue) {
                return const Icon(Icons.star_rounded, color: Colors.amber, size: 16);
              } else if (ratingValue > starValue - 1 && ratingValue < starValue) {
                return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 16);
              } else {
                return Icon(Icons.star_border_rounded, color: Colors.grey.shade400, size: 16);
              }
            }),
          )
        else
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ================= GLASS EFFECT CHIP TAG
class _GlassTag extends StatelessWidget {
  final String text;

  const _GlassTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}