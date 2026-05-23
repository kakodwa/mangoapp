import 'package:flutter/material.dart';

import '../../models/lodge_model.dart';
import '../../screens/hospitality/lodge_detail_screen.dart';
import '../../screens/hospitality/add_room_screen.dart';
import '../../screens/hospitality/edit_lodge_screen.dart';


class LodgeCard extends StatefulWidget {
  final Lodge lodge;
  final bool isOwner;

  const LodgeCard({
    super.key,
    required this.lodge,
    this.isOwner = false,
  });

  @override
  State<LodgeCard> createState() => _LodgeCardState();
}

class _LodgeCardState extends State<LodgeCard> {
  bool isFavorite = false;

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Lodge"),
        content: const Text("Are you sure you want to delete this lodge?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint("DELETE lodge: ${widget.lodge.id}");
              // TODO: call delete API here
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            )
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lodge = widget.lodge;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LodgeDetailScreen(lodge: lodge),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= IMAGE + ACTIONS =================
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: lodge.images.isNotEmpty
                      ? Image.network(
                          lodge.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(color: Colors.grey.shade300),
                ),

                /// ❤️ FAVORITE BUTTON
               /// ❤️ FAVORITE BUTTON (HIDE IF OWNER)
if (!widget.isOwner)
  Positioned(
    top: 10,
    right: 10,
    child: GestureDetector(
      onTap: () {
        setState(() {
          isFavorite = !isFavorite;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite
              ? Icons.favorite
              : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.black54,
          size: 22,
        ),
      ),
    ),
  ),

                /// 🏨 OWNER ACTIONS (VERTICAL UNDER HEART)
                if (widget.isOwner)
                  Positioned(
                    top: 60,
                    right: 10,
                    child: Column(
                      children: [

                        /// ADD ROOM
                        _buildActionButton(
                          icon: Icons.meeting_room,
                          color: Colors.green,
                          tooltip: "Add Room",
                          onTap: () {
                            debugPrint("Add Room: ${lodge.id}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddRoomScreen(lodgeId: lodge.id),
                                ),
                              );
                            },
                        ),

                        const SizedBox(height: 8),

                        /// EDIT
                        /// EDIT
_buildActionButton(
  icon: Icons.edit,
  color: Colors.blue,
  tooltip: "Edit Lodge",
  onTap: () async {
    debugPrint("Edit Lodge: ${lodge.id}");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditLodgeScreen(
          lodge: lodge,
        ),
      ),
    );

    /// OPTIONAL REFRESH
    if (result == true && mounted) {
      setState(() {});
    }
  },
),

                        const SizedBox(height: 8),

                        /// DELETE
                        _buildActionButton(
                          icon: Icons.delete,
                          color: Colors.red,
                          tooltip: "Delete Lodge",
                          onTap: () {
                            _showDeleteDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            /// ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lodge.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (lodge.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text('${lodge.city}, ${lodge.district}'),
                  const SizedBox(height: 8),
                  Text(lodge.lodgeType.toUpperCase()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}