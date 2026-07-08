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
  int _currentIndex = 0;
  bool _hasLoggedView = false;
  final ScrollController _scrollController = ScrollController();

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
                              setState(() => _currentIndex = index);
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

                      // Modern linear ambient layout gradient matrix
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

                      // Location Overlay Badge Element
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

                      // Slider Modern Dot Indicators Layout
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
                                width: _currentIndex == index ? 16 : 6,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index
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

              // ================= MAIN CONTENT DESCRIPTION CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Named Merchant Partner Header Specification
                              Text(
                                widget.lodge.name,
                                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Text(
                                "About Lodge",
                                style: AppTypography.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.lodge.description,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: const Text(
                          'Available Rooms',
                          style: AppTypography.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ================= AVAILABLE ROOMS CATALOG SLIDER BINDING
                      roomsAsync.when(
                        data: (rooms) {
                          if (rooms.isEmpty) {
                            return AppCard(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.hotel_outlined,
                                      size: 56,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      "No rooms available yet",
                                      style: AppTypography.titleMedium.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 350,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rooms.length,
                              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                              
                                final bool isOwner = isLoggedIn && 
                                user?.id != null && 
                                user?.id == room.ownerId;

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
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            e.toString(),
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= REUSABLE CUSTOMER REVIEWS SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ReviewSectionWidget(
                    targetType: 'lodge',
                    targetId: widget.lodge.id,
                    isOwner: isLoggedIn && user?.id == widget.lodge.ownerId,
                  ),
                ),
              ),

              // Dynamic structural padding allowance overlay spacing depth for FAB layout actions
              const SliverToBoxAdapter(child: SizedBox(height: 160)),
              const SliverToBoxAdapter(
                child: WebFooter(),
                ),
            ],
          ),

          // ================= FLOATING ACTION SIDE NAVIGATION UTILITY PANEL
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 💬 SOCIAL CONNECT WHATSAPP ACTION FAB BOUND
                AppFab(
                  heroTag: "whatsapp_lodge_fab",
                  icon: FontAwesomeIcons.whatsapp,
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
        : "https://mangobackend-yayy.onrender.com/lodge/${widget.lodge.id}";

    final String shareMessage =
        "🏨 ${widget.lodge.name}\n"
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

          final extension = imageUrl
              .split('.')
              .last
              .split('?')
              .first
              .toLowerCase();

          final validExtension =
              ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
                  ? extension
                  : 'jpg';

          final file = await File(
            '${tempDir.path}/shared_lodge_${widget.lodge.id}.$validExtension',
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
      debugPrint("Lodge share failed: $e");

      await Share.share(
        shareMessage,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  },
),
                const SizedBox(height: AppSpacing.sm),

                // 🗺 MAP ACCESSIBILITY FAB BOUND WITH COORDINATE VERIFICATION
                if (widget.lodge.latitude != null && widget.lodge.longitude != null)
                  AppFab(
                    heroTag: "map_lodge_fab",
                    icon: Icons.map_outlined,
                    tooltip: "Open Geolocation Tracking",
                    onPressed: () {
                      _analyticsService.logEvent('lodge_map_view_${widget.lodge.id}');
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ShopMapModal(
                          shopLat: widget.lodge.latitude!,
                          shopLng: widget.lodge.longitude!,
                        ),
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
}