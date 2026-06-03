import 'package:flutter/material.dart';

import '../../models/lodge_model.dart';
import '../../screens/hospitality/add_room_screen.dart';
import '../../screens/hospitality/edit_lodge_screen.dart';
import '../../screens/hospitality/lodge_detail_screen.dart';

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
  bool _pressed = false;

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Lodge"),
        content: const Text(
          "Are you sure you want to delete this lodge?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint("DELETE lodge: ${widget.lodge.id}");
              // TODO: Delete API
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
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lodge = widget.lodge;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration:
                const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                LodgeDetailScreen(lodge: lodge),
            transitionsBuilder:
                (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ================= IMAGE =================

              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: AnimatedScale(
                      duration:
                          const Duration(milliseconds: 250),
                      scale: _pressed ? 1.08 : 1.0,
                      child: SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: lodge.images.isNotEmpty
                            ? Image.network(
                                lodge.images.first,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) {
                                  return Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.hotel,
                                      size: 50,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(
                                  Icons.hotel,
                                  size: 50,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Gradient Overlay

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(
                              .45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // TOP BADGES

                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            lodge.lodgeType
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: lodge.isVerified
                                ? Colors.green
                                : Colors.orange,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            lodge.isVerified
                                ? "VERIFIED"
                                : "PENDING",
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FAVORITE BUTTON

                  if (!widget.isOwner)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isFavorite =
                                !isFavorite;
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(
                            10,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: Colors.white,
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),

                  // OWNER ACTIONS

                  if (widget.isOwner)
                    Positioned(
                      top: 55,
                      right: 12,
                      child: Column(
                        children: [
                          _buildActionButton(
                            icon:
                                Icons.meeting_room,
                            color: Colors.green,
                            tooltip:
                                "Add Room",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddRoomScreen(
                                    lodgeId:
                                        lodge.id,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.blue,
                            tooltip:
                                "Edit Lodge",
                            onTap: () async {
                              final result =
                                  await Navigator
                                      .push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditLodgeScreen(
                                    lodge: lodge,
                                  ),
                                ),
                              );

                              if (result ==
                                      true &&
                                  mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            tooltip:
                                "Delete Lodge",
                            onTap: () {
                              _showDeleteDialog(
                                context,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // ================= INFO =================

              Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lodge.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                          ),
                        ),
                        if (lodge.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 18,
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${lodge.city}, ${lodge.district}",
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .labelSmall,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}