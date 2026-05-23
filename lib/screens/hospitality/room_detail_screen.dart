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
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  title: Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
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
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.hotel,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.hotel,
                                  size: 80,
                                  color: Colors.white,
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
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.7),
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ================= STATUS + ROOM NUMBER =================
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: room.isAvailable
                                  ? Colors.green.withOpacity(.1)
                                  : Colors.red.withOpacity(.1),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: Text(
                              room.isAvailable
                                  ? "Available"
                                  : "Not Available",
                              style: TextStyle(
                                color: room.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(.1),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Room ${room.roomNumber}",
                              style: const TextStyle(
                                color: Colors.orange,
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
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      /// ================= PRICE CARD =================
                      AppCard(
                        padding:
                            const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    Colors.orange.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.payments,
                                color: Colors.orange,
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

                                  const SizedBox(height: 4),

                                  Text(
                                    "Per Night",
                                    style: TextStyle(
                                      color:
                                          Colors.grey.shade600,
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
                      const Text(
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
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AppCard(
                        padding:
                            const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          room.description.isEmpty
                              ? "No description provided."
                              : room.description,
                          style: TextStyle(
                            height: 1.7,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                       AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.hotel_class,
                                color: Colors.orange,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
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
                      ? Colors.orange
                      : Colors.grey,
                  textColor: Colors.white,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.orange,
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