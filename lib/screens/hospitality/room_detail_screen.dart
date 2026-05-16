import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import 'booking_checkout_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// ================= SCROLL CONTENT =================
          CustomScrollView(
            slivers: [

              /// ===== IMAGE HEADER =====
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(room.title),
                  background: Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.hotel,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              /// ===== BODY =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// STATUS + ROOM NUMBER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: room.isAvailable
                                  ? Colors.green.withOpacity(.1)
                                  : Colors.red.withOpacity(.1),
                              borderRadius: BorderRadius.circular(8),
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

                          Text(
                            "Room ${room.roomNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// TITLE
                      Text(
                        room.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        room.roomType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// PRICE
                      Text(
                        "MWK ${room.pricePerNight} / night",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// CAPACITY CARD
                      _infoCard(
                        icon: Icons.people,
                        title: "Capacity",
                        value: "${room.capacity} Guests",
                      ),

                      const SizedBox(height: 16),

                      /// AMENITIES
                      const Text(
                        "Amenities",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (room.hasWifi)
                            _amenity(Icons.wifi, "WiFi"),
                          if (room.hasTv)
                            _amenity(Icons.tv, "TV"),
                          if (room.hasAc)
                            _amenity(Icons.ac_unit, "Air Conditioning"),
                          if (room.hasBreakfast)
                            _amenity(Icons.free_breakfast, "Breakfast"),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// DESCRIPTION
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        room.description.isEmpty
                            ? "No description provided."
                            : room.description,
                        style: const TextStyle(height: 1.5),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  )
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: room.isAvailable
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    onPressed: room.isAvailable
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BookingCheckoutScreen(room: room),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      room.isAvailable
                          ? "Book Now"
                          : "Room Not Available",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Text("$title: ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  /// ================= AMENITY CHIP =================
  Widget _amenity(IconData icon, String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.orange),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}