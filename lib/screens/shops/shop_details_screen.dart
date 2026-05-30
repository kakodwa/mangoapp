import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';

import '../../widgets/shop_map_modal.dart';
import '../../widgets/app_fab.dart';

import '../auth/login_screen.dart';
import '../products/product_card.dart';
import 'shop_card.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../utils/app_toast.dart';

class ShopDetailsScreen extends ConsumerStatefulWidget {
  final int shopId;

  const ShopDetailsScreen({super.key, required this.shopId});

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  void _openWhatsApp(BuildContext context, String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.info(context, "Could not open WhatsApp");
    }
  }


    void _callPhone(String phone) async {
    final uri = Uri.parse("tel:$phone");
    await launchUrl(uri);
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse("mailto:$email");
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopDetailsProvider(widget.shopId));
    final productsAsync = ref.watch(productsByShopProvider(widget.shopId));
    final relatedShopsAsync = ref.watch(relatedShopsProvider(widget.shopId));
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: shopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),

        data: (shop) {
          return Stack(
            children: [

              // ================= MAIN SCROLL
              CustomScrollView(
                slivers: [

                  // ================= INSTAGRAM STYLE HEADER
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.black,
                    leading: const BackButton(color: Colors.white),

                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [

                          // Banner image
                          shop.banner != null && shop.banner!.isNotEmpty
                              ? Image.network(
                                  shop.banner!,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey.shade300),

                          // Dark overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.6),
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),

                          // CATEGORY
                          Positioned(
                            top: 60,
                            left: 16,
                            child: _GlassTag(text: shop.category),
                          ),

                          // VERIFIED
                          Positioned(
                            top: 60,
                            right: 16,
                            child: Row(
                              children: [
                                Icon(
                                  shop.status == 'approved'
                                      ? Icons.verified
                                      : Icons.lock,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  shop.status == 'approved'
                                      ? "Verified"
                                      : "Pending",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // ================= PROFILE SECTION (INSTAGRAM STYLE)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [

                                    // LOGO
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: CircleAvatar(
                                        radius: 34,
                                        backgroundImage: shop.logo.isNotEmpty
                                            ? NetworkImage(shop.logo)
                                            : null,
                                        child: shop.logo.isEmpty
                                            ? const Icon(Icons.store)
                                            : null,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // NAME + LOCATION
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shop.name,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 14,
                                                  color: Colors.white70),
                                              const SizedBox(width: 4),
                                              Text(
                                                shop.district,
                                                style: const TextStyle(
                                                    color: Colors.white70),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // ================= STATS ROW
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _StatItem(
                                      title: "Products",
                                      value: "${shop.productCount ?? 0}",
                                    ),
                                    _StatItem(
                                      title: "Rating",
                                      value: "${shop.rating}",
                                    ),
                                    _StatItem(
                                      title: "Reviews",
                                      value: "${shop.totalReviews}",
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


              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ================= NAME + STATS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      Text(
                        shop.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

                


                  // ================= CONTACT CARD (NEW BELOW DESCRIPTION)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.05),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Contact Business",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // PHONE
                        Row(
                          children: [
                            const Icon(Icons.phone, color:AppColors.mangoOrange),
                            const SizedBox(width: 10),
                            Expanded(child: Text(shop.phoneNumber)),
                            IconButton(
                              icon: const Icon(Icons.call,color:AppColors.leafGreen),
                              onPressed: () => _callPhone(shop.phoneNumber),
                            ),
                          ],
                        ),

                        // EMAIL
                        Row(
                          children: [
                            const Icon(Icons.email, color: AppColors.mangoOrange),
                            const SizedBox(width: 10),
                            Expanded(child: Text(shop.email)),
                            IconButton(
                              icon: const Icon(Icons.send,color:AppColors.leafGreen),
                              onPressed: () => _sendEmail(shop.email),
                            ),
                          ],
                        ),

                        // WHATSAPP
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.whatsapp,color: AppColors.mangoOrange,),
                            const SizedBox(width: 10),
                            const Expanded(child: Text("WhatsApp Chat")),
                            IconButton(
                              icon: const Icon(Icons.message,color:AppColors.leafGreen),
                              onPressed: () {
                                if (!isLoggedIn) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
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

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // ================= PRODUCTS
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Products",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  productsAsync.when(
                    loading: () => const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator())),
                    error: (e, _) =>
                        SliverToBoxAdapter(child: Text("Error: $e")),
                    data: (products) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) =>
                                ProductCard(product: products[i]),
                            childCount: products.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                        ),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 120)),
                ],
              ),

              // ================= FLOATING ACTIONS
              Positioned(
                bottom: 20,
                right: 16,
                child: Column(
                  children: [

                    AppFab(
                      heroTag: "fav",
                      icon: Icons.favorite_border,
                      tooltip: "Favorite",
                      toastMessage: "Saved",
                      onPressed: () {},
                    ),

                    const SizedBox(height: 12),

                    AppFab(
                      heroTag: "whatsapp",
                      icon: FontAwesomeIcons.whatsapp,
                      tooltip: "WhatsApp",
                      toastMessage: "Opening chat",
                      onPressed: () {
                        if (!isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                          return;
                        }

                        final phone = shop.phoneNumber;
                        if (phone.isEmpty) {
                          AppToast.info(context, "No phone number");
                          return;
                        }

                        _openWhatsApp(context, phone);
                      },
                    ),

                    const SizedBox(height: 12),

                    AppFab(
                      heroTag: "map",
                      icon: Icons.map_outlined,
                      tooltip: "Map",
                      toastMessage: "Opening map",
                      onPressed: () {
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
    );
  }
}

// ================= STAT ITEM
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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
}

// ================= GLASS TAG
class _GlassTag extends StatelessWidget {
  final String text;

  const _GlassTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}