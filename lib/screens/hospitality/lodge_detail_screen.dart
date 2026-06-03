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
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/shop_map_modal.dart';
import '../../theme/app_colors.dart';
import '../../widgets/hospitality/room_card.dart';
import '../../utils/app_toast.dart';
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
    final isLoggedIn = authState.isAuthenticated;


    void _openWhatsApp(String phone) async {
          final uri = Uri.parse("https://wa.me/$phone");

          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            AppToast.info(context, "Could not open WhatsApp");
            }
          }

    return Scaffold(
      
      appBar: roomsAsync.when(
        data: (_) => MainAppBar(title: lodge.name),
        loading: () => const MainAppBar(title: "Loading..."),
        error: (_, __) =>
            const MainAppBar(title: "Details"),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              /// ================= HERO APP BAR =================
              SliverAppBar(
                expandedHeight: 320,
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.surface),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  titlePadding: EdgeInsets.only(
                    left: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  title: Text(
                    lodge.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
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
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.surface,
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
                              Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                              Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),

                      /// LOCATION BADGE
                      Positioned(
                        left: 16,
                        bottom: 60,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.surface,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${lodge.city}, ${lodge.district}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
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
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DESCRIPTION
                      AppCard(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                      Text(
                        'Available Rooms',
                         style: AppTypography.headlineLarge,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      /// ================= ROOMS =================
                      roomsAsync.when(
                        data: (rooms) {
                          if (rooms.isEmpty) {
                            return AppCard(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.hotel_outlined,
                                    size: 60,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
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
                            height: 350,
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
                          padding: EdgeInsets.all(20),
                          child: Text(
                            e.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error),
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
    bottom:50,
    right: 16,
    child: Column(
      children: [

              // 💬 WHATSAPP BUTTON
        AppFab(
          heroTag: "whatsapp",
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

            final phone = lodge.phoneNumber;

            if (phone == null || phone.isEmpty) {
              AppToast.info(
                context,
                "No WhatsApp number available",
              );
              return;
            }

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
        ),

        


      ],
    ),
  ),
        ],
      ),
    );
  }
}