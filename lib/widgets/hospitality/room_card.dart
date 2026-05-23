import 'package:flutter/material.dart';

import '../../models/room_model.dart';
<<<<<<< HEAD

import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';

=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import '../../screens/hospitality/room_detail_screen.dart';

class RoomCard extends StatelessWidget {
  final Room room;
<<<<<<< HEAD
  final List<String> lodgeImages;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

  const RoomCard({
    super.key,
    required this.room,
<<<<<<< HEAD
    required this.lodgeImages,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return SizedBox(
      width: 260,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= IMAGE =================
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: lodgeImages.isNotEmpty
                        ? Image.network(
                            lodgeImages.isNotEmpty
                                ? lodgeImages.first
                                : '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.hotel, size: 50),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.hotel, size: 50),
                          ),
                  ),
                ),

                /// STATUS BADGE
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: room.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      room.isAvailable ? "Available" : "Booked",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// OWNER ACTIONS
                if (isOwner)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Row(
                      children: [
                        _actionButton(
                          icon: Icons.edit,
                          color: Colors.blue,
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            /// ================= DETAILS =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      room.roomType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.meeting_room,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Room ${room.roomNumber}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "MWK ${room.pricePerNight}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: "View Room",
                        icon: Icons.visibility,
                        type: AppButtonType.secondary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomDetailScreen(
                                room: room,
                                lodgeImages: lodgeImages,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
=======
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(room.description),
            const SizedBox(height: 12),
            Text('MWK ${room.pricePerNight}/night'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomDetailScreen(room: room),
                  ),
                );
              },
              child: const Text('View Room'),
            ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

  static Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.edit, color: Colors.white, size: 18),
        ),
      ),
    );
  }
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
}