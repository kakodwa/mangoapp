// lib/screens/shops/shop_details_screen.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert';

import 'package:universal_html/html.dart' as html; 

import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart'; 

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
import '../main_tabs_screen.dart'; 

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

  final List<Product> _extendedProducts = [];
  int _currentPage = 2; 
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
      final url = "https://malatrade.com/api/shops/${widget.shopId}/products/?page=$_currentPage";
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
        final blob = html.Blob([bytes], 'image/png');
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement() 
          ..href = blobUrl 
          ..download = fileName; 
          
        html.document.body?.append(anchor); 
        anchor.click(); 
        anchor.remove(); 
        html.Url.revokeObjectUrl(blobUrl); 
        
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
                "MalaTrade Marketplace",
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

  Widget _buildMainTabBody(Shop shop, AsyncValue<List<Product>> productsAsync, bool isLoggedIn, double screenWidth) {
    if (_selectedTabIndex == 0) {
      return productsAsync.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())), 
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text("Error: $e")), 
        data: (baseProducts) {
          final List<Product> combinedList = [...baseProducts, ..._extendedProducts];

          if (combinedList.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No products available from this vendor.")));
          }

          return Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: combinedList.length,
                itemBuilder: (context, i) => ProductCard(product: combinedList[i]),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getResponsiveCrossAxisCount(screenWidth), 
                  childAspectRatio: 0.62, 
                  crossAxisSpacing: 12, 
                  mainAxisSpacing: 12, 
                ),
              ),
              if (_isLoadingMore)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            ],
          );
        },
      );
    } else if (_selectedTabIndex == 1) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const Text("About Store", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
            const SizedBox(height: AppSpacing.xs), 
            Text(shop.description, style: TextStyle(color: Colors.grey.shade700, height: 1.4)), 
          ],
        ),
      );
    } else if (_selectedTabIndex == 2) {
      return Padding(
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
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md), 
        child: ReviewSectionWidget(targetType: 'shop', targetId: shop.id, isOwner: false), 
      );
    }
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
    final bool isDesktop = screenWidth >= 900;

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

            final List<Map<String, dynamic>> tabList = [
              {"title": "Products", "icon": Icons.grid_view_rounded},
              {"title": "About Shop", "icon": Icons.info_outline_rounded},
              {"title": "Contact", "icon": Icons.call_outlined},
              {"title": "Review", "icon": Icons.star_outline_rounded},
            ];

            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController, 
                  slivers: [
                    // ================= BANNER & LOGO HEADER =================
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Full Banner Container
                              Container(
                                height: 180,
                                width: double.infinity,
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                                child: (shop.banner != null && shop.banner!.isNotEmpty)
                                    ? Image.network(
                                        shop.banner!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(child: Icon(Icons.store, size: 60));
                                        },
                                      )
                                    : const Center(child: Icon(Icons.store, size: 60)),
                              ),

                              // Gradient overlay
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),

                              // Top Category Tag
                              Positioned(
                                top: AppSpacing.md,
                                left: AppSpacing.md,
                                child: _GlassTag(text: shop.category),
                              ),

                              // Top Status Badge
                              Positioned(
                                top: AppSpacing.md,
                                right: AppSpacing.md,
                                child: AppBadge(
                                  text: shop.status == 'approved' ? "Verified" : "Pending",
                                  type: shop.status == 'approved' ? BadgeType.success : BadgeType.warning,
                                ),
                              ),

                              // Floating Circle Logo Overlay
                              Positioned(
                                bottom: -30,
                                left: AppSpacing.md,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  child: (shop.logo.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            shop.logo,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 30),
                                          ),
                                        )
                                      : const Icon(Icons.store, size: 30),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Shop Title & District Line
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop.name,
                                  style: AppTypography.displaySmall.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      shop.district,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🌟 TRANSPARENT ORANGE CARD FOR PRODUCTS, RATING, REVIEWS
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.mangoOrange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.mangoOrange.withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),
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

                    // ================= RESPONSIVE LAYOUT SWITCH =================
                    if (isDesktop) ...[
                      // 💻 DESKTOP: SIDEBAR NAVIGATION + CONTENT PANE
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT SIDEBAR MENU
                              Container(
                                width: 220,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: List.generate(tabList.length, (index) {
                                    final isSelected = _selectedTabIndex == index;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: ListTile(
                                        dense: true,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        tileColor: isSelected ? AppColors.mangoOrange.withOpacity(0.12) : Colors.transparent,
                                        leading: Icon(
                                          tabList[index]["icon"] as IconData,
                                          size: 20,
                                          color: isSelected ? AppColors.mangoOrange : Colors.grey.shade600,
                                        ),
                                        title: Text(
                                          tabList[index]["title"] as String,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? AppColors.mangoOrange : Colors.grey.shade800,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedTabIndex = index;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ),

                              const SizedBox(width: AppSpacing.md),

                              // RIGHT DETAIL PANE
                              Expanded(
                                child: _buildMainTabBody(shop, productsAsync, isLoggedIn, screenWidth),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // 📱 MOBILE: TOP TAB BAR
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

                      SliverToBoxAdapter(
                        child: _buildMainTabBody(shop, productsAsync, isLoggedIn, screenWidth),
                      ),
                    ],

                    // Web/Desktop Footer
                    const SliverToBoxAdapter(
                      child: WebFooter(),
                    ),
                  ],
                ),

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
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,            
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
                          _analytics.logEvent('shop_shared_${widget.shopId}');

                          final String shopUrl = kIsWeb
                              ? "${Uri.base.origin}/shop/${widget.shopId}"
                              : "https://malatrade.com/shop/${widget.shopId}";

                          final String shareMessage =
                              "🛍️ ${shop.name}\n"
                              "📂 Category: ${shop.category}\n"
                              "📍 Location: ${shop.district}, Malawi\n\n"
                              "Browse this shop on MalaTrade:\n$shopUrl";

                          final box = context.findRenderObject() as RenderBox?;
                          final sharePositionOrigin =
                              box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                          try {
                            String? imageUrl;

                            if (shop.logo.isNotEmpty) {
                              imageUrl = shop.logo;
                            } else if (shop.banner != null && shop.banner!.isNotEmpty) {
                              imageUrl = shop.banner!;
                            }

                            if (imageUrl != null) {
                              final response = await http.get(Uri.parse(imageUrl));

                              if (response.statusCode == 200) {
                                final tempDir = await getTemporaryDirectory();

                                final extension = imageUrl
                                    .split('.')
                                    .last
                                    .split('?')
                                    .first
                                    .toLowerCase();

                                final validExtension = ['jpg', 'jpeg', 'png', 'webp']
                                        .contains(extension)
                                    ? extension
                                    : 'jpg';

                                final file = await File(
                                  '${tempDir.path}/shared_shop_${shop.id}.$validExtension',
                                ).create();

                                await file.writeAsBytes(response.bodyBytes);

                                await Share.shareXFiles(
                                  [XFile(file.path)],
                                  text: shareMessage,
                                  sharePositionOrigin: sharePositionOrigin,
                                );

                                return;
                              }
                            }

                            await Share.share(
                              shareMessage,
                              sharePositionOrigin: sharePositionOrigin,
                            );
                          } catch (e) {
                            debugPrint("Shop share failed: $e");

                            await Share.share(
                              shareMessage,
                              sharePositionOrigin: sharePositionOrigin,
                            );
                          }
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
                          MainTabsScreen.of(context)?.navigateToShopMap(
                            shop.latitude, 
                            shop.longitude,
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