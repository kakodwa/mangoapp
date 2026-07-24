// lib/screens/hospitality/lodge_detail_screen.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/web_footer.dart';
import '../../models/lodge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rooms_provider.dart';

import '../auth/login_screen.dart';
import '../main_tabs_screen.dart'; 

import '../../widgets/app_fab.dart';
import '../../widgets/shop_map_modal.dart';
import '../../widgets/reviews/review_section_widget.dart';
import '../../widgets/hospitality/room_card.dart';

import '../../utils/app_snackbar.dart';
import '../../utils/app_toast.dart';

// Design System Imports
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/app_colors.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class LodgeDetailScreen extends ConsumerStatefulWidget {
  final Lodge lodge;

  const LodgeDetailScreen({
    super.key,
    required this.lodge,
  });

  @override
  ConsumerState<LodgeDetailScreen> createState() => _LodgeDetailScreenState();
}

class _LodgeDetailScreenState extends ConsumerState<LodgeDetailScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  int _carouselIndex = 0;
  bool _hasLoggedView = false;
  
  // Clean standard Flutter ScrollController initialization
  final ScrollController _scrollController = ScrollController();
  
  // Interactive tab selector state variable ('rooms' active by default)
  String _activeTab = 'rooms'; 

  void _openWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.info(context, "Could not open WhatsApp");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoggedView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analyticsService.logEvent('view_lodge_detail_${widget.lodge.id}');
      });
      _hasLoggedView = true;
    }

    final roomsAsync = ref.watch(roomsProvider(widget.lodge.id));
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoggedIn = authState.isAuthenticated;
    final images = widget.lodge.images;

    return Material(
      color: const Color(0xFFF8F9FA),
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ================= HERO IMAGE CAROUSEL FRAME
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (images.isEmpty)
                        Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        )
                      else
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 340,
                            viewportFraction: 1.0,
                            autoPlay: images.length > 1,
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              setState(() => _carouselIndex = index);
                            },
                          ),
                          items: images.map((image) {
                            return CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: AppSpacing.md,
                        bottom: AppSpacing.xl,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.lodge.city}, ${widget.lodge.district}',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (images.length > 1)
                        Positioned(
                          bottom: AppSpacing.md,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 6,
                                width: _carouselIndex == index ? 16 : 6,
                                decoration: BoxDecoration(
                                  color: _carouselIndex == index
                                      ? AppColors.primary(context)
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ================= MAIN TITLED HEADER CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md, left: AppSpacing.md, right: AppSpacing.md),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lodge.name,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= MODERN INTERACTIVE TAB SEGMENT BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(id: 'rooms', label: 'Available Rooms'),
                        _buildTabButton(id: 'about', label: 'About Lodge'),
                        _buildTabButton(id: 'reviews', label: 'Reviews'),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= DYNAMIC CONDITIONAL TAB CONTENT LAYER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ TAB SECTION 1: AVAILABLE ROOMS (WITH LAZY-LOADED RESPONSIVE RESPONSIVE GRID)
                      if (_activeTab == 'rooms') ...[
                        roomsAsync.when(
                          data: (rooms) {
                            if (rooms.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: AppCard(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.hotel_outlined, size: 56, color: Colors.grey.shade400),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          "No rooms available yet",
                                          style: AppTypography.titleMedium.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Evaluate breakpoint configurations on layout constraints dynamically
                            final double width = MediaQuery.of(context).size.width;
                            int crossAxisCount = 1; 
                            if (width >= 600 && width < 900) crossAxisCount = 2;   // Tablet
                            if (width >= 900 && width < 1300) crossAxisCount = 3;  // Laptop
                            if (width >= 1300) crossAxisCount = 4;                 // Big Screen Desktop

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(), // Hands scrolling management over to master scroll controller
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: AppSpacing.md,
                                  mainAxisSpacing: AppSpacing.md,
                                  mainAxisExtent: 355, // Locks structured explicit matching card aspect card heights
                                ),
                                itemCount: rooms.length,
                                itemBuilder: (context, index) {
                                  final room = rooms[index];
                                  final bool isOwner = isLoggedIn && user?.id != null && user?.id == room.ownerId;

                                  // Lazy Infinite Scrolling Pagination Trigger Interceptor Hook
                                  if (index == rooms.length - 1) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      // Optional hook point to dispatch fetch signals onto paginated providers
                                      // ref.read(roomsProvider(widget.lodge.id).notifier).fetchNextBatch();
                                      debugPrint("🚀 Infinite Scroll threshold reached on index $index! Lazy loading next collection parameters...");
                                    });
                                  }

                                  return RoomCard(
                                    room: room,
                                    lodgeImages: widget.lodge.images,
                                    isOwner: isOwner,
                                    onEdit: () {
                                      _analyticsService.logEvent('lodge_room_edit_click_${room.id}');
                                      debugPrint("Edit room: ${room.id}");
                                    },
                                    onDelete: () {
                                      _analyticsService.logEvent('lodge_room_delete_click_${room.id}');
                                      debugPrint("Delete room: ${room.id}");
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: CircularProgressIndicator())),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(e.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ),
                        ),
                      ],

                      // TAB SECTION 2: ABOUT LODGE DESCRIPTION
                      if (_activeTab == 'about') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("About Lodge", style: AppTypography.headlineMedium),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    widget.lodge.description,
                                    style: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade700, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      // TAB SECTION 3: CUSTOMER REVIEWS
                      if (_activeTab == 'reviews') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: ReviewSectionWidget(
                            targetType: 'lodge',
                            targetId: widget.lodge.id,
                            isOwner: isLoggedIn && user?.id == widget.lodge.ownerId,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 160)),
              const SliverToBoxAdapter(child: WebFooter()),
            ],
          ),

          // ================= FLOATING ACTION SIDE NAVIGATION UTILITY PANEL
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               AppFab(
  heroTag: "whatsapp_lodge_fab",
  icon: FontAwesomeIcons.whatsapp,
  backgroundColor: const Color(0xFF25D366), 
  foregroundColor: Colors.white,            
  tooltip: "Chat on WhatsApp",
  onPressed: () {
    if (!isLoggedIn) {
      _analyticsService.logEvent('lodge_whatsapp_unauthenticated_redirect');
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final phone = widget.lodge.phoneNumber;
    if (phone.isEmpty) {
      AppToast.info(context, "No WhatsApp contact channel available");
      return;
    }

    _analyticsService.logEvent('lodge_whatsapp_chat_start_${widget.lodge.id}');
    _openWhatsApp(phone);
  },
),
                const SizedBox(height: AppSpacing.sm),

                AppFab(
                  heroTag: "share_lodge_fab",
                  icon: Icons.share_outlined,
                  tooltip: "Share Lodge Listing",
                  onPressed: () async {
                    _analyticsService.logEvent('lodge_shared_${widget.lodge.id}');

                    final String lodgeUrl = kIsWeb
                        ? "${Uri.base.origin}/lodge/${widget.lodge.id}"
                        : "https://malatrade.com/lodge/${widget.lodge.id}";

                    final String shareMessage =
                        "🏡 ${widget.lodge.name}\n"
                        "📍 ${widget.lodge.city}, ${widget.lodge.district}\n\n"
                        "Browse rooms and book your stay on MangoHub:\n"
                        "$lodgeUrl";

                    final box = context.findRenderObject() as RenderBox?;
                    final sharePositionOrigin =
                        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                    try {
                      if (widget.lodge.images.isNotEmpty) {
                        final imageUrl = widget.lodge.images.first;
                        final response = await http.get(Uri.parse(imageUrl));

                        if (response.statusCode == 200) {
                          final tempDir = await getTemporaryDirectory();
                          final extension = imageUrl.split('.').last.split('?').first.toLowerCase();
                          final validExtension = ['jpg', 'jpeg', 'png', 'webp'].contains(extension) ? extension : 'jpg';

                          final file = await File('${tempDir.path}/shared_lodge_${widget.lodge.id}.$validExtension').create();
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
                      debugPrint("Lodge share failed: $e");
                      await Share.share(shareMessage, sharePositionOrigin: sharePositionOrigin);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                if (widget.lodge.latitude != null && widget.lodge.longitude != null)
                  AppFab(
  heroTag: "map_lodge_fab",
  icon: Icons.map_outlined,
  tooltip: "Open Geolocation Tracking",
  onPressed: () {
    _analyticsService.logEvent('lodge_map_view_${widget.lodge.id}');
    // Triggers navigation through MainTabsScreen's IndexedStack router
    MainTabsScreen.of(context)?.navigateToShopMap(
      widget.lodge.latitude!,
      widget.lodge.longitude!,
    );
  },
),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern tab segment button builder helper
  Widget _buildTabButton({required String id, required String label}) {
    final bool isSelected = _activeTab == id;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _analyticsService.logEvent('lodge_detail_tab_switch_$id');
          setState(() => _activeTab = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected 
                ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}