import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../screens/hospitality/room_detail_screen.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}