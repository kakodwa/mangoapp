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
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';
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

  bool _isLandProperty(String type) {
    final value = type.toLowerCase();
    return value.contains('land') ||
        value.contains('plot') ||
        value.contains('farm');
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
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyDetailsProvider(widget.propertyId));
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final AnalyticsService analytics = AnalyticsService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: propertyAsync.when(
        data: (property) => AppBar(
          title: Text(property.title),
        ),
        loading: () => AppBar(
          title: const Text('Loading...'),
        ),
        error: (_, __) => AppBar(
          title: const Text('Property Detail'),
        ),
      ),
      body: propertyAsync.when(
        data: (property) {
          final currentUserId = authState.user?.id;
          final relatedAsync = ref.watch(relatedPropertiesProvider(property.id));
          final isOwner = currentUserId == property.ownerId;
          final isLand = _isLandProperty(property.propertyType);

          // 📊 TRACK EVENT: Screen renders loaded item details successfully
          if (!_hasLoggedView) {
            analytics.logEvent('property_details_view');
            _hasLoggedView = true;
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 🖼 IMAGE HEADER / CAROUSEL
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: property.images.isNotEmpty
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

                                        // gradient overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                                                Colors.transparent,
                                                Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // primary badge
                                        if (image.isPrimary)
                                          Positioned(
                                            top: 50,
                                            right: 16,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.mangoOrange,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Primary',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.surface,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // alt text
                                        if (image.altText != null && image.altText!.isNotEmpty)
                                          Positioned(
                                            left: 16,
                                            bottom: 20,
                                            right: 16,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                image.altText!,
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.surface,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),

                                // image counter
                                if (property.images.length > 1)
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${property.images.length} Photos',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.surface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.home,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // 📄 CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🏷 TITLE
                          Text(
                            property.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),

                          const SizedBox(height: 10),

                          // 🏠 PURPOSE + TYPE
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildTag(
                                property.listingPurpose.toUpperCase(),
                                AppColors.mangoOrange,
                              ),
                              _buildTag(
                                property.propertyType.toUpperCase(),
                                Theme.of(context).colorScheme.primary,
                              ),
                              _buildTag(
                                property.status.toUpperCase(),
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 💰 PRICE
                          Text(
                            '${property.currency} ${property.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mangoOrange,
                                ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 📍 LOCATION
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.mangoOrange,
                              ),
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

                          // 📊 DETAILS GRID
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              _buildDetail(
                                context,
                                Icons.category,
                                'Type',
                                property.propertyType,
                              ),
                              _buildDetail(
                                context,
                                Icons.sell,
                                'Purpose',
                                property.listingPurpose,
                              ),
                              _buildDetail(
                                context,
                                Icons.check_circle,
                                'Status',
                                property.status,
                              ),
                              if (!isLand && property.bedrooms != null)
                                _buildDetail(
                                  context,
                                  Icons.bed,
                                  'Bedrooms',
                                  '${property.bedrooms}',
                                ),
                              if (!isLand && property.bathrooms != null)
                                _buildDetail(
                                  context,
                                  Icons.bathroom,
                                  'Bathrooms',
                                  '${property.bathrooms}',
                                ),
                              _buildDetail(
                                context,
                                Icons.square_foot,
                                'Size',
                                '${property.sizeSqm} sqm',
                              ),
                              _buildDetail(
                                context,
                                Icons.visibility,
                                'Views',
                                '${property.viewCount}',
                              ),
                              _buildDetail(
                                context,
                                Icons.public,
                                'Visibility',
                                property.isPubliclyVisible ? 'Public' : 'Private',
                              ),
                              _buildDetail(
                                context,
                                Icons.calendar_today,
                                'Listed',
                                '${property.createdAt.day}/${property.createdAt.month}/${property.createdAt.year}',
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 📜 DESCRIPTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(property.description),
                            ],
                          ),

                          // 🔒 LOCK SECTION
                          if (!property.isUnlocked && !isOwner)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.mangoOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.mangoOrange.withOpacity(0.4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: AppColors.mangoOrange,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          'Full Details Locked',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: AppColors.mangoOrange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Unlock this property to view full description, exact location, and contact details.',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Unlock Fee'),
                                      Text(
                                        'MWK ${property.unlockFee.toStringAsFixed(0)}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: AppColors.mangoOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.mangoOrange,
                                      ),
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
                                      child: Text(
                                        'Unlock for MWK ${property.unlockFee.toStringAsFixed(0)}',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: AppSpacing.md),

                          // 👤 OWNER
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Property Owner',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.mangoOrange.withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.mangoOrange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              property.ownerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.verified,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ================= RELATED PROPERTIES =================
                          const SizedBox(height: 25),
                          Text(
                            "Related Properties",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 340,
                            child: relatedAsync.when(
                              data: (items) {
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                      width: 280,
                                      child: PropertyCard(property: items[index]),
                                    );
                                  },
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, stack) {
                                debugPrint(e.toString());
                                debugPrint(stack.toString());
                                return Center(
                                  child: Text(
                                    "Failed to load related properties\n$e",
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ FLOATING BUTTONS GATED BY UNLOCKED STATUS (MAP & WHATSAPP)
              if (property.isUnlocked)
                Positioned(
                  bottom: 100, // Adjusted layout position offset
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🗺 MAP FAB
                      AppFab(
                        heroTag: "map",
                        icon: Icons.map,
                        tooltip: "View Map",
                        toastMessage: "Opening map",
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

                      // 💬 WHATSAPP FAB
                      AppFab(
                        heroTag: "whatsapp_property",
                        icon: FontAwesomeIcons.whatsapp,
                        tooltip: "Chat on WhatsApp",
                        toastMessage: "Opening WhatsApp...",
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

                          final phone = property.ownerPhoneNumber;

                          if (phone == null || phone.isEmpty) {
                            AppToast.info(
                              context,
                              "Mailing reference invalid or missing",
                            );
                            return;
                          }

                          analytics.logEvent('property_details_whatsapp_click');
                          _openWhatsApp(phone);
                        },
                      ),
                    ],
                  ),
                ),

              // ✅ ALWAYS VISIBLE SHARE BUTTON (OUTSIDE CONDITION)
              Positioned(
                bottom: 20,
                right: 16,
                child: AppFab(
                  heroTag: "share_product",
                  icon: Icons.share_outlined,
                  tooltip: "Share Product",
                  onPressed: () async {
                    analytics.logEvent('product_shared_${property.id}');

                    // 1. Determine the product URL structure
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

                        // 2. Download the network image into bytes
                        final response = await http.get(Uri.parse(imageUrl));

                        if (response.statusCode == 200) {
                          // 3. Save bytes into a temporary directory file
                          final tempDir = await getTemporaryDirectory();

                          // Extract original extension or default to .jpg
                          final String extension = imageUrl.split('.').last.split('?').first;
                          final String validExtension = ['jpg', 'jpeg', 'png', 'webp'].contains(extension.toLowerCase()) ? extension : 'jpg';

                          final file = await File('${tempDir.path}/shared_product_${property.id}.$validExtension').create();
                          await file.writeAsBytes(response.bodyBytes);

                          // 4. Wrap file into an XFile wrapper
                          final XFile xFile = XFile(file.path);

                          // 5. Share both the image file and text parameters together
                          await Share.shareXFiles(
                            [xFile],
                            text: shareMessage,
                            sharePositionOrigin: sharePositionOrigin,
                          );
                          return;
                        }
                      }
                      
                      // Fallback text-only sharing if no images exist or image download fails
                      await Share.share(
                        shareMessage,
                        sharePositionOrigin: sharePositionOrigin,
                      );
                    } catch (e) {
                      if (mounted) {
                        AppToast.info(context, "Could not bundle media for sharing. Sharing text instead.");
                      }
                      await Share.share(
                        shareMessage,
                        sharePositionOrigin: sharePositionOrigin,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error rendering view: $error'),
        ),
      ),
    );
  }

  // UI Helpers definitions
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}