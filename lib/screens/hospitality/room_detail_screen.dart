import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/shop_map_modal.dart';
import '../../widgets/hospitality/room_card.dart';
import 'availability_calendar_screen.dart';
import 'booking_checkout_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;
  final List<String> lodgeImages;

  const RoomDetailScreen({
    super.key,
    required this.room,
    required this.lodgeImages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          /// ================= MAIN SCROLL =================
          CustomScrollView(
            slivers: [
              /// ================= IMAGE HEADER =================
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                iconTheme: const IconThemeData(color: Theme.of(context).colorScheme.surface),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  title: Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
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
                      /// ================= IMAGE SLIDER =================
                      lodgeImages.isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(
                                height: 320,
                                viewportFraction: 1,
                                autoPlay: true,
                                enlargeCenterPage: false,
                              ),
                              items: lodgeImages.map((image) {
                                return Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                                      child: const Center(
                                        child: Icon(
                                          Icons.hotel,
                                          size: 70,
                                          color: Theme.of(context).colorScheme.surface,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                              child: const Center(
                                child: Icon(
                                  Icons.hotel,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),

                      /// ================= DARK OVERLAY =================
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                              Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ================= BODY =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ================= STATUS + ROOM NUMBER =================
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: room.isAvailable
                                  ? Theme.of(context).colorScheme.secondary.withOpacity(.1)
                                  : Theme.of(context).colorScheme.error.withOpacity(.1),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: Text(
                              room.isAvailable
                                  ? "Available"
                                  : "Not Available",
                              style: TextStyle(
                                color: room.isAvailable
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Room ${room.roomNumber}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ================= ROOM TITLE =================
                      Text(
                        room.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        room.roomType.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ================= PRICE CARD =================
                      AppCard(
                        padding:
                            EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.payments,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            const SizedBox(
                              width: AppSpacing.md,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "MWK ${room.pricePerNight}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xxs),

                                  Text(
                                    "Per Night",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ================= CAPACITY =================
                      _infoCard(
                        icon: Icons.people,
                        title: "Capacity",
                        value: "${room.capacity} Guests",
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ================= AMENITIES =================
                      Text(
                        "Amenities",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (room.hasWifi)
                            _amenity(Icons.wifi, "WiFi"),

                          if (room.hasTv)
                            _amenity(Icons.tv, "TV"),

                          if (room.hasAc)
                            _amenity(
                              Icons.ac_unit,
                              "Air Conditioning",
                            ),

                          if (room.hasBreakfast)
                            _amenity(
                              Icons.free_breakfast,
                              "Breakfast",
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      /// ================= DESCRIPTION =================
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AppCard(
                        padding:
                            EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          room.description.isEmpty
                              ? "No description provided."
                              : room.description,
                          style: TextStyle(
                            height: 1.7,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                       AppCard(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.hotel_class,
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Plan Your Stay",
                                    style: AppTypography.headlineLarge,
                                    ),
                                  
                                  const SizedBox(height: 5),
                                  Text(
                                    "Check room availability and booking dates.",
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Flexible(
                              child: AppButton(
                                text: "Check",
                                icon: Icons.calendar_month,
                                type: AppButtonType.secondary,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AvailabilityCalendarScreen(
                                        roomId: room.id,
                                        ),
                                      ),
                                    );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// ================= BOOK BUTTON =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: SafeArea(
                child: AppButton(
                  text: room.isAvailable
                      ? "Book Now"
                      : "Room Not Available",
                  icon: Icons.calendar_month,
                  fullWidth: true,
                  backgroundColor: room.isAvailable
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  textColor: Theme.of(context).colorScheme.surface,
                  onPressed: room.isAvailable
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingCheckoutScreen(
                                room: room,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= INFO CARD =================
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(value),
        ],
      ),
    );
  }

  /// ================= AMENITY CHIP =================
  Widget _amenity(
    IconData icon,
    String label,
  ) {
    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(width: AppSpacing.xs),

          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}