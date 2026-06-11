// lib/screens/properties/property_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

import '../auth/login_screen.dart';
import '../../utils/app_toast.dart';
import '../../providers/properties_provider.dart';
import '../../providers/api_provider.dart';
import '../../widgets/shop_map_modal.dart';
import '../../widgets/reviews/review_section_widget.dart';
import '../../theme/app_colors.dart';
import 'property_unlock_screen.dart';
import 'property_card.dart';
import '../../widgets/app_fab.dart';
import '../../providers/auth_provider.dart';
import '../../theme/design_system/app_spacing.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  final int propertyId;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  bool _hasLoggedView = false;
  final ScrollController _scrollController = ScrollController();

  bool _isLandProperty(String type) {
    final value = type.toLowerCase();
    return value.contains('land') || value.contains('plot') || value.contains('farm');
  }

  void _openWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        AppToast.info(context, "Could not open WhatsApp");
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyDetailsProvider(widget.propertyId));
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final AnalyticsService analytics = AnalyticsService();

    return Material(
      color: const Color(0xFFF5F7FA),
      child: propertyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error rendering view: $error')),
        data: (property) {
          final currentUserId = authState.user?.id;
          final relatedAsync = ref.watch(relatedPropertiesProvider(property.id));
          final isOwner = currentUserId == property.ownerId;
          final isLand = _isLandProperty(property.propertyType);

          if (!_hasLoggedView) {
            analytics.logEvent('property_details_view');
            _hasLoggedView = true;
          }

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ================= PREMIUM PROPERTY MEDIA GALLERY FRAME
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: property.images.isNotEmpty
                          ? Stack(
                              children: [
                                PageView.builder(
                                  itemCount: property.images.length,
                                  itemBuilder: (context, index) {
                                    final image = property.images[index];
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          image.image,
                                          fit: BoxFit.cover,
                                        ),
                                        // Modern dynamic linear ambient layout gradient
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.15),
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.35),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Primary Status Badge Anchor layout positioning
                                        if (image.isPrimary)
                                          Positioned(
                                            top: AppSpacing.sm,
                                            right: AppSpacing.md,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: AppColors.mangoOrange,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'Primary',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        // Meta Image Annotation Overlay text strings
                                        if (image.altText != null && image.altText!.isNotEmpty)
                                          Positioned(
                                            left: AppSpacing.md,
                                            bottom: AppSpacing.lg,
                                            right: AppSpacing.md,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                image.altText!,
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                // Photo Counter Stack Indicator Layer
                                if (property.images.length > 1)
                                  Positioned(
                                    right: AppSpacing.md,
                                    bottom: AppSpacing.md,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.64),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${property.images.length} Photos',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.home_work_outlined, size: 80, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),

                  // ================= CORE DATA SPECIFICATIONS SHEET
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Metadata Header Tag Row
                          Text(
                            property.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildTag(property.listingPurpose.toUpperCase(), AppColors.mangoOrange),
                              _buildTag(property.propertyType.toUpperCase(), Theme.of(context).colorScheme.primary),
                              _buildTag(property.status.toUpperCase(), Theme.of(context).colorScheme.secondary),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Premium Display Currency Format Pricing Section
                          Text(
                            '${property.currency} ${property.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mangoOrange,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Explicit Gated Location Mapping Address String
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.mangoOrange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  property.isUnlocked || isOwner
                                      ? '${property.address}, ${property.city}, ${property.district}, Malawi'
                                      : '${property.city}, ${property.district}, Malawi',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Parametric Grid Dimension Matrix Cards
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              _buildDetail(context, Icons.category, 'Type', property.propertyType),
                              _buildDetail(context, Icons.sell, 'Purpose', property.listingPurpose),
                              _buildDetail(context, Icons.check_circle, 'Status', property.status),
                              if (!isLand && property.bedrooms != null)
                                _buildDetail(context, Icons.bed, 'Bedrooms', '${property.bedrooms}'),
                              if (!isLand && property.bathrooms != null)
                                _buildDetail(context, Icons.bathroom, 'Bathrooms', '${property.bathrooms}'),
                              _buildDetail(context, Icons.square_foot, 'Size', '${property.sizeSqm} sqm'),
                              _buildDetail(context, Icons.visibility, 'Views', '${property.viewCount}'),
                              _buildDetail(context, Icons.calendar_today, 'Listed', '${property.createdAt.day}/${property.createdAt.month}/${property.createdAt.year}'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Content Paragraph Summary
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            property.description,
                            style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                          ),
                          
                          // ================= GATEWAY TRANSACTION CONTENT LOCK
                          if (!property.isUnlocked && !isOwner)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.mangoOrange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.mangoOrange.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.lock, color: AppColors.mangoOrange),
                                      SizedBox(width: AppSpacing.xs),
                                      Text(
                                        'Full Details Locked',
                                        style: TextStyle(color: AppColors.mangoOrange, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Unlock this property to view full description, exact location map tracking coordinates, and contact business phone lines directly.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Unlock Premium Fee', style: TextStyle(fontWeight: FontWeight.w500)),
                                      Text(
                                        'MWK ${property.unlockFee.toStringAsFixed(0)}',
                                        style: const TextStyle(color: AppColors.mangoOrange, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.mangoOrange,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {
                                        if (!isLoggedIn) {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PropertyUnlockScreen(
                                              propertyId: property.id,
                                              propertyTitle: property.title,
                                              unlockFee: property.unlockFee,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Unlock for MWK ${property.unlockFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: AppSpacing.md),
                          // Business Affiliation Details
                          Text(
                            'Property Owner',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.mangoOrange.withOpacity(0.1),
                                  child: const Icon(Icons.person, color: AppColors.mangoOrange, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.ownerName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 14),
                                          const SizedBox(width: 4),
                                          const Text('Verified Merchant Partner', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  // ================= CUSTOMER REVIEWS SECTION SLIVER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: ReviewSectionWidget(
                        targetType: 'property',
                        targetId: property.id,
                        isOwner: isOwner,
                      ),
                    ),
                  ),

                  // ================= RELATED MODEL CATALOG HORIZONTAL SLIDER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            "Related Properties",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            height: 260,
                            child: relatedAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text("Failed to load catalog feeds: $e")),
                              data: (items) {
                                if (items.isEmpty) {
                                  return const Center(child: Text("No immediate matching listings found nearby."));
                                }
                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                      width: 200,
                                      child: PropertyCard(property: items[index]),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 160)),
                ],
              ),

              // ================= FLOATING ACTION ACCESSIBILITY STACK GATED ROUTING
              if (property.isUnlocked || isOwner)
                Positioned(
                  bottom: 90,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppFab(
                        heroTag: "map_coord_fab",
                        icon: Icons.map_outlined,
                        tooltip: "View Geolocation Map",
                        onPressed: () {
                          analytics.logEvent('property_details_map_click');
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => ShopMapModal(
                              shopLat: property.latitude,
                              shopLng: property.longitude,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppFab(
                        heroTag: "whatsapp_prop_fab",
                        icon: FontAwesomeIcons.whatsapp,
                        tooltip: "Chat on WhatsApp",
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            return;
                          }
                          final phone = property.ownerPhoneNumber;
                          if (phone == null || phone.isEmpty) {
                            AppToast.info(context, "Owner profile contact configurations missing");
                            return;
                          }
                          analytics.logEvent('property_details_whatsapp_click');
                          _openWhatsApp(phone);
                        },
                      ),
                    ],
                  ),
                ),

              // ================= ALWAYS VISIBLE SECURE RICH MEDIA SHARE BUTTON
              Positioned(
                bottom: 20,
                right: 16,
                child: AppFab(
                  heroTag: "share_property_fab",
                  icon: Icons.share_outlined,
                  tooltip: "Share Listing Profile",
                  onPressed: () async {
                    analytics.logEvent('product_shared_${property.id}');

                    final String productUrl = kIsWeb
                        ? "${Uri.base.origin}/property/${property.id}"
                        : "https://mangobackend-yayy.onrender.com/property/${property.id}";

                    final String shareMessage =
                        "Check out ${property.title} on Mangochi Marketplace!\nPrice: MWK ${property.price}\n\nView details here: $productUrl";

                    final box = context.findRenderObject() as RenderBox?;
                    final sharePositionOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                    try {
                      if (property.images.isNotEmpty) {
                        final imageUrl = property.images.first.image;
                        final response = await http.get(Uri.parse(imageUrl));

                        if (response.statusCode == 200) {
                          final tempDir = await getTemporaryDirectory();
                          final String extension = imageUrl.split('.').last.split('?').first;
                          final String validExtension = ['jpg', 'jpeg', 'png', 'webp'].contains(extension.toLowerCase()) ? extension : 'jpg';

                          final file = await File('${tempDir.path}/shared_prop_${property.id}.$validExtension').create();
                          await file.writeAsBytes(response.bodyBytes);

                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text: shareMessage,
                            sharePositionOrigin: sharePositionOrigin,
                          );
                          return;
                        }
                      }
                      await Share.share(shareMessage, sharePositionOrigin: sharePositionOrigin);
                    } catch (e) {
                      await Share.share(shareMessage, sharePositionOrigin: sharePositionOrigin);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}