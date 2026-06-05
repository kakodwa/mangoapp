// lib/screens/hospitality/lodge_detail_screen.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/lodge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rooms_provider.dart';

import '../auth/login_screen.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_fab.dart';
import '../../widgets/shop_map_modal.dart';
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

  void _openWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.info(context, "Could not open WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📊 TRACK EVENT: Safe async trigger on frame registration
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

    // Fixed safeImage error: Use widget.lodge.images directly
    final images = widget.lodge.images;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: roomsAsync.when(
          data: (_) => Text(widget.lodge.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Details'),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              
              // ================= HERO IMAGE CAROUSEL
              SliverAppBar(
                expandedHeight: 340,
                automaticallyImplyLeading: false,
                pinned: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (images.isEmpty)
                        // Fallback block if lodge has no images at all
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

                      // Subtle Dark Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Location Overlay Badge
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
                              color: Colors.white.withOpacity(0.2),
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

              // ================= MAIN CONTENT DESCRIPTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                      const SizedBox(height: AppSpacing.lg),

                      const Text(
                        'Available Rooms',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ================= AVAILABLE ROOMS CARDS HORIZONTAL SCROLL
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
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                                final bool isOwner = user?.id != null &&
                                    room.ownerId != null &&
                                    user!.id == room.ownerId;

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

                      const SizedBox(height: 120), // Padding allowance overlay space depth for FABs
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ================= RESTORED FLOATING ACTION UTILITY STACK
          if (widget.lodge.latitude != null && widget.lodge.longitude != null)
            Positioned(
              bottom: 50,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // 💬 WHATSAPP BUTTON
                  AppFab(
                    heroTag: "whatsapp",
                    icon: FontAwesomeIcons.whatsapp,
                    tooltip: "Chat on WhatsApp",
                    toastMessage: "Opening WhatsApp...",
                    onPressed: () {
                      if (!isLoggedIn) {
                        _analyticsService.logEvent('lodge_whatsapp_unauthenticated_redirect');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                        return;
                      }

                      final phone = widget.lodge.phoneNumber;
                      if (phone == null || phone.isEmpty) {
                        AppToast.info(context, "No WhatsApp number available");
                        return;
                      }

                      _analyticsService.logEvent('lodge_whatsapp_chat_start_${widget.lodge.id}');
                      _openWhatsApp(phone);
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // 🗺 MAP BUTTON
                  AppFab(
                    heroTag: "map_lodge",
                    icon: Icons.map,
                    tooltip: "View Map",
                    toastMessage: "Opening map",
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