// lib/screens/hospitality/room_detail_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/shop_map_modal.dart';
import '../main_tabs_screen.dart'; 
import 'availability_calendar_screen.dart';
import 'booking_checkout_screen.dart';
import '../../providers/rooms_provider.dart';
import '../../widgets/web_footer.dart';
import '../main_tabs_screen.dart';

class RoomDetailScreen extends ConsumerWidget {
  final Room room;
  final List<String> lodgeImages;

  const RoomDetailScreen({
    super.key,
    required this.room,
    required this.lodgeImages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    Widget imageGallery = Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: lodgeImages.isNotEmpty
              ? CarouselSlider(
                  options: CarouselOptions(
                    height: isDesktop ? 420 : 320,
                    viewportFraction: 1,
                    autoPlay: lodgeImages.length > 1,
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
                            child: Icon(Icons.hotel, size: 70, color: Colors.white),
                          ),
                        );
                      },
                    );
                  }).toList(),
                )
              : Container(
                  height: 320,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                  child: const Center(
                    child: Icon(Icons.hotel, size: 80, color: Colors.white),
                  ),
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    Widget detailsSpecificationSheet = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: room.isAvailable
                    ? Theme.of(context).colorScheme.secondary.withOpacity(.1)
                    : Theme.of(context).colorScheme.error.withOpacity(.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                room.isAvailable ? "Available" : "Not Available",
                style: TextStyle(
                  color: room.isAvailable
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                borderRadius: BorderRadius.circular(30),
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
        const SizedBox(height: AppSpacing.md),
        Text(room.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          room.roomType.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.payments, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("MWK ${room.pricePerNight}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text("Per Night", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _infoCard(
          context: context,
          icon: Icons.people,
          title: "Capacity",
          value: "${room.capacity} Guests",
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text("Amenities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (room.hasWifi) _amenity(context, Icons.wifi, "WiFi"),
            if (room.hasTv) _amenity(context, Icons.tv, "TV"),
            if (room.hasAc) _amenity(context, Icons.ac_unit, "Air Conditioning"),
            if (room.hasBreakfast) _amenity(context, Icons.free_breakfast, "Breakfast"),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            room.description.isEmpty ? "No description provided." : room.description,
            style: TextStyle(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Plan Your Stay", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Check calendar metrics.", style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                text: "Check",
                icon: Icons.calendar_month,
                type: AppButtonType.secondary,
                onPressed: () {
                  MainTabsScreen.of(context)?.navigateToAvailabilityCalendar(room.id);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isDesktop)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: AppButton(
              text: room.isAvailable ? "Book This Room Now" : "Room Currently Unavailable",
              icon: Icons.bolt,
              backgroundColor: room.isAvailable ? Theme.of(context).colorScheme.primary : Colors.grey,
              textColor: Colors.white,
              onPressed: room.isAvailable
                  ? () {
                      MainTabsScreen.of(context)?.navigateToBookingCheckout(room);
                    }
                  : null,
            ),
          ),
      ],
    );

    // returns plain view layout safely embedded below the MainAppBar scaffolding
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: !isDesktop
                        ? Column(
                            children: [
                              imageGallery,
                              const SizedBox(height: AppSpacing.md),
                              detailsSpecificationSheet,
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: imageGallery),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(flex: 6, child: detailsSpecificationSheet),
                            ],
                          ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: WebFooter(),
                ),
              ),
            ],
          ),
        ),
        if (!isDesktop)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black12)],
              ),
              child: AppButton(
                text: room.isAvailable ? "Book Now" : "Room Not Available",
                icon: Icons.calendar_month,
                fullWidth: true,
                backgroundColor: room.isAvailable
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                textColor: Theme.of(context).colorScheme.surface,
                onPressed: room.isAvailable
                    ? () {
                        MainTabsScreen.of(context)?.navigateToBookingCheckout(room);
                      }
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoCard({
    required BuildContext context,
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _amenity(BuildContext context, IconData icon, String label) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}