// lib/screens/shops/shop_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'dart:js_interop'; 

import 'package:web/web.dart' as web; 

import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart'; // 🌟 Keeps your working provider intact

import '../../widgets/shop_map_modal.dart';
import '../../widgets/app_fab.dart';
import '../../widgets/reviews/review_section_widget.dart';
import '../../widgets/web_footer.dart';

import '../auth/login_screen.dart';
import '../products/product_card.dart';
import 'shop_card.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../utils/app_toast.dart';

import '../../models/shop_model.dart'; 
import '../../models/product_model.dart'; 
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
  
  int _selectedTabIndex = 0;

  // 🌟 INLINE HYBRID PAGINATION SYSTEM
  final List<Product> _extendedProducts = [];
  int _currentPage = 2; // Initial page is fetched by provider, so we start at 2
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _selectedTabIndex != 0) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Trigger lazy loading of page 2+ when reaching 90% of the screen
    if (currentScroll >= (maxScroll * 0.9)) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Points exactly to your live deployed render target
      final url = "https://mangobackend-yayy.onrender.com/api/shops/${widget.shopId}/products/?page=$_currentPage";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        List<dynamic> newRawProducts = [];

        if (decodedBody is Map<String, dynamic>) {
          newRawProducts = decodedBody['results'] ?? [];
          _hasMore = decodedBody['next'] != null;
        } else if (decodedBody is List) {
          newRawProducts = decodedBody;
          _hasMore = false;
        }

        final List<Product> parsed = newRawProducts
            .map((jsonMap) => Product.fromJson(jsonMap as Map<String, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _extendedProducts.addAll(parsed);
            _currentPage++;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _isLoadingMore = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

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

  int _getResponsiveCrossAxisCount(double width) {
    if (width < 600) return 2;     
    if (width < 900) return 3;     
    if (width < 1200) return 4;    
    return 5;                      
  }

  Future<void> _downloadOrSaveQr(BuildContext context, String url, String shopName) async {
    try {
      AppToast.info(context, "Preparing file download...");

      final response = await http.get(Uri.parse(url)); 
      if (response.statusCode != 200) throw Exception("Image fetch failed"); 
      final bytes = response.bodyBytes; 
      final fileName = "${shopName.replaceAll(' ', '_')}_QR.png"; 

      if (kIsWeb) {
        final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png')); 
        final blobUrl = web.URL.createObjectURL(blob); 
        
        final anchor = web.HTMLAnchorElement() 
          ..href = blobUrl 
          ..download = fileName; 
          
        web.document.body?.append(anchor); 
        anchor.click(); 
        anchor.remove(); 
        web.URL.revokeObjectURL(blobUrl); 
        
        if (context.mounted) {
          AppToast.info(context, "QR image saved to your local device downloads."); 
        }
      } else {
        final hasAccess = await Gal.hasAccess(); 
        if (!hasAccess) {
          await Gal.requestAccess(); 
        }

        await Gal.putImageBytes(bytes, name: fileName.replaceAll('.png', '')); 
        
        if (context.mounted) {
          AppToast.info(context, "Success! QR saved to your photos/gallery."); 
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.info(context, "Error saving file. Check your device permissions."); 
      }
    }
  }

  Widget _buildPrintableQrCard(Shop shop) { 
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade100, width: 1), 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const Icon(Icons.shopping_bag, color: AppColors.mangoOrange, size: 20), 
              const SizedBox(width: 6), 
              Text(
                "MangoHub Marketplace",
                style: TextStyle(
                  color: Colors.grey.shade800, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13, 
                ),
              ),
            ],
          ),
          const Divider(height: 20), 
          Text(
            shop.name.toUpperCase(),
            textAlign: TextAlign.center, 
            style: const TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 18, 
              letterSpacing: 0.5, 
              color: AppColors.darkText, 
            ),
          ),
          const SizedBox(height: 4), 
          Text(
            "Scan to browse our digital shop!",
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12), 
          ),
          const SizedBox(height: 16), 
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(14), 
              border: Border.all(color: Colors.grey.shade200, width: 2), 
            ),
            child: shop.qrCode != null 
                ? Image.network(
                    shop.qrCode!, 
                    height: 220, 
                    width: 220, 
                    fit: BoxFit.contain, 
                  )
                : const SizedBox(
                    height: 220, 
                    width: 220, 
                    child: Center(child: CircularProgressIndicator()), 
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopDetailsProvider(widget.shopId)); 
    final productsAsync = ref.watch(productsByShopProvider(widget.shopId)); 
    final auth = ref.watch(authProvider); 
    final isLoggedIn = auth.isAuthenticated; 
    
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
                                ? Image.network(shop.banner!, fit: BoxFit.cover) 
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
                            Positioned(
                              top: AppSpacing.md, 
                              left: AppSpacing.md, 
                              child: _GlassTag(text: shop.category), 
                            ),
                            Positioned(
                              top: AppSpacing.md, 
                              right: AppSpacing.md, 
                              child: AppBadge(
                                text: shop.status == 'approved' ? "Verified" : "Pending", 
                                type: shop.status == 'approved' ? BadgeType.success : BadgeType.warning, 
                              ),
                            ),
                            Positioned(
                              bottom: AppSpacing.md, 
                              left: AppSpacing.md, 
                              right: AppSpacing.md, 
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2), 
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white), 
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
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), 
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.white70), 
                                            const SizedBox(width: 4), 
                                            Text(shop.district, style: const TextStyle(color: Colors.white70)), 
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
                      productsAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())), 
                        ),
                        error: (e, _) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Text("Error: $e"))), 
                        data: (baseProducts) {
                          // 🌟 Merge your working Riverpod first-page products list with our scrolling layout lists
                          final List<Product> combinedList = [...baseProducts, ..._extendedProducts];

                          if (combinedList.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No products available from this vendor."))), 
                            );
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: AppSpacing.md), 
                            sliver: SliverMainAxisGroup(
                              slivers: [
                                SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) => ProductCard(product: combinedList[i]), 
                                    childCount: combinedList.length,
                                  ),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _getResponsiveCrossAxisCount(screenWidth), 
                                    childAspectRatio: 0.62, 
                                    crossAxisSpacing: 12, 
                                    mainAxisSpacing: 12, 
                                  ),
                                ),
                                if (_isLoadingMore)
                                  const SliverToBoxAdapter(
                                    child: Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else if (_selectedTabIndex == 1) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md), 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              const Text("About Store", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                              const SizedBox(height: AppSpacing.xs), 
                              Text(shop.description, style: TextStyle(color: Colors.grey.shade700, height: 1.4)), 
                            ],
                          ),
                        ),
                      ),
                    ] else if (_selectedTabIndex == 2) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md), 
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                const Text("Contact Business", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
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
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); 
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
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md), 
                          child: ReviewSectionWidget(targetType: 'shop', targetId: shop.id, isOwner: false), 
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 140)), 
                    const SliverToBoxAdapter(child: WebFooter()), 
                  ],
                ),

                // ================= FLOATING ACTION SIDE NAVIGATION PANEL
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
                          // 🌟 FIX: Added the hash segment (/慶/) for direct URL sharing security stability
                          final String shopUrl = kIsWeb
                              ? "${Uri.base.origin}/#/shop/${widget.shopId}" 
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
                        heroTag: "qr_shop_fab",
                        icon: Icons.qr_code_2_outlined, 
                        tooltip: "Show Store QR Code",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
                              contentPadding: const EdgeInsets.all(AppSpacing.md), 
                              backgroundColor: Colors.white, 
                              content: Column(
                                mainAxisSize: MainAxisSize.min, 
                                children: [
                                  _buildPrintableQrCard(shop), 
                                  const SizedBox(height: 12), 
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
                                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)), 
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center, 
                                      children: [
                                        Icon(Icons.analytics_outlined, size: 16, color: Colors.grey.shade600), 
                                        const SizedBox(width: 6), 
                                        Text(
                                          "Total Customer Scans: ${shop.qrScanCount ?? 0}", 
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600), 
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actionsAlignment: MainAxisAlignment.spaceBetween, 
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext), 
                                  child: Text("Close", style: TextStyle(color: Colors.grey.shade600)), 
                                ),
                                if (shop.qrCode != null) 
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.leafGreen, 
                                      foregroundColor: Colors.white, 
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                                    ),
                                    onPressed: () {
                                      Navigator.pop(dialogContext); 
                                      _downloadOrSaveQr(context, shop.qrCode!, shop.name); 
                                    },
                                    icon: Icon(kIsWeb ? Icons.download_outlined : Icons.save_alt_outlined, size: 18), 
                                    label: Text(kIsWeb ? "Download Image" : "Save to Gallery"), 
                                  ),
                              ],
                            ),
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
                            builder: (_) => ShopMapModal(shopLat: shop.latitude, shopLng: shop.longitude), 
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height; 
  @override
  double get maxExtent => _tabBar.preferredSize.height; 

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overridesParagraphs) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: _tabBar); 
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false; 
}

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
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)), 
        const SizedBox(height: 4), 
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)), 
      ],
    );
  }
}

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
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), 
    );
  }
}