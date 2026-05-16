import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lodge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rooms_provider.dart';
import '../../widgets/shop_map_modal.dart';
import 'availability_calendar_screen.dart';
import 'room_detail_screen.dart';

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
      body: Stack(
        children: [

          /// ================= MAIN SCROLL =================
          CustomScrollView(
            slivers: [

              /// ================= APP BAR + IMAGE SLIDER =================
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(lodge.name),
                  background: CarouselSlider(
                    options: CarouselOptions(
                      viewportFraction: 1,
                      autoPlay: true,
                    ),
                    items: lodge.images.map((image) {
                      return Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    }).toList(),
                  ),
                ),
              ),

              /// ================= CONTENT =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(lodge.description),
                      const SizedBox(height: 12),
                      Text('${lodge.city}, ${lodge.district}'),
                      const SizedBox(height: 20),

                      /// ================= BOOKING CARD =================
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Plan Your Stay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AvailabilityCalendarScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.calendar_month),
                                label: const Text("Check Availability"),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Available Rooms',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ================= ROOMS LIST =================
                      roomsAsync.when(
                        data: (rooms) {
                          if (rooms.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text("No rooms available yet"),
                            );
                          }

                          return SizedBox(
                            height: 320,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rooms.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final room = rooms[index];

                                final bool isOwner =
                                    user?.id != null &&
                                    room.ownerId != null &&
                                    user!.id == room.ownerId;

                                debugPrint(
                                  "USER:${user?.id} | ROOM OWNER:${room.ownerId}",
                                );

                                return Container(
                                  width: 240,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// ================= IMAGE + OWNER BUTTONS =================
                                      Stack(
                                        children: [
                                          Container(
                                            height: 120,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              color: Colors.grey,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.hotel,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),

                                          /// OWNER ACTIONS (TOP RIGHT VERTICAL)
                                          if (isOwner)
                                            Positioned(
                                              right: 6,
                                              top: 6,
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      padding: const EdgeInsets.all(6),
                                                    ),
                                                    onPressed: () {
                                                      debugPrint("Edit Room: ${room.id}");
                                                    },
                                                  ),
                                                  const SizedBox(height: 6),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      padding: const EdgeInsets.all(6),
                                                    ),
                                                    onPressed: () {
                                                      debugPrint("Delete Room: ${room.id}");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: room.isAvailable
                                                        ? Colors.green.withOpacity(0.1)
                                                        : Colors.red.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    room.isAvailable
                                                        ? "Available"
                                                        : "Booked",
                                                    style: TextStyle(
                                                      color: room.isAvailable
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "Room ${room.roomNumber}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              room.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              room.roomType.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              "MWK ${room.pricePerNight}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            /// ================= FULL WIDTH VIEW BUTTON =================
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          RoomDetailScreen(room: room),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.visibility),
                                                label: const Text("View Room"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(e.toString()),
                      ),
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
              child: FloatingActionButton(
                backgroundColor: Colors.orange,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ShopMapModal(
                      shopLat: lodge.latitude!,
                      shopLng: lodge.longitude!,
                    ),
                  );
                },
                child: const Icon(Icons.map),
              ),
            ),
        ],
      ),
    );
  }
}