import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lodge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rooms_provider.dart';

import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

import '../../widgets/shop_map_modal.dart';
import '../../widgets/hospitality/room_card.dart';

import 'availability_calendar_screen.dart';

class LodgeDetailScreen extends ConsumerWidget {
  final Lodge lodge;

  const LodgeDetailScreen({
    super.key,
    required this.lodge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider(lodge.id));
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              /// ================= HERO APP BAR =================
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  titlePadding: const EdgeInsets.only(
                    left: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  title: Text(
                    lodge.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 320,
                          viewportFraction: 1,
                          autoPlay: true,
                          enlargeCenterPage: false,
                        ),
                        items: lodge.images.map((image) {
                          return Image.network(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      /// DARK OVERLAY
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),

                      /// LOCATION BADGE
                      Positioned(
                        left: 16,
                        bottom: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${lodge.city}, ${lodge.district}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ================= MAIN CONTENT =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DESCRIPTION
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "About Lodge",
                              style: AppTypography.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              lodge.description,
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(height: AppSpacing.xl),

                      /// SECTION HEADER
                      const Text(
                        'Available Rooms',
                         style: AppTypography.headlineLarge,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      /// ================= ROOMS =================
                      roomsAsync.when(
                        data: (rooms) {
                          if (rooms.isEmpty) {
                            return AppCard(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.hotel_outlined,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    "No rooms available yet",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return SizedBox(
                            height: 380,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rooms.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final room = rooms[index];

                                final bool isOwner =
                                    user?.id != null &&
                                        room.ownerId != null &&
                                        user!.id == room.ownerId;

                                return RoomCard(
                                  room: room,
                                  lodgeImages: lodge.images,
                                  isOwner: isOwner,
                                  onEdit: () {
                                    debugPrint("Edit room: ${room.id}");
                                  },
                                  onDelete: () {
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
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            e.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// ================= MAP BUTTON =================
          if (lodge.latitude != null && lodge.longitude != null)
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: "mapBtn",
                backgroundColor: Colors.orange,
                elevation: 4,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ShopMapModal(
                      shopLat: lodge.latitude!,
                      shopLng: lodge.longitude!,
                    ),
                  );
                },
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  "View Map",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}