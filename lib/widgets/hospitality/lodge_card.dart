// lib/widgets/hospitality/lodge_card.dart

import 'package:flutter/material.dart';

import '../../models/lodge_model.dart';
import '../../screens/hospitality/add_room_screen.dart';
import '../../screens/hospitality/edit_lodge_screen.dart';
import '../../screens/main_tabs_screen.dart'; // Updated to point to main_tabs_screen_2.dart

import '../../widgets/capitalize_text.dart';

// Design System Imports
import '../../theme/design_system/app_icon_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_image_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_spacing.dart';

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
        title: const Text("DELETE LODGE"),
        content: const Text("ARE YOU SURE YOU WANT TO DELETE THIS LODGE?"), 
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint("DELETE lodge: ${widget.lodge.id}");
            },
            child: Text(
              "DELETE",
              style: TextStyle(color: AppColors.error(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lodge = widget.lodge;

    final List<Widget> cardBadges = [
      AppBadge(
        text: lodge.lodgeType.toUpperCase(),
        type: BadgeType.primary,
      ),
      AppBadge(
        text: lodge.isVerified ? "VERIFIED" : "PENDING",
        type: lodge.isVerified ? BadgeType.success : BadgeType.warning,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(
        left: 2.0,
        right: 2.0,
        bottom: AppSpacing.sm,
      ),
      child: AppCard(
        padding: EdgeInsets.zero, 
        onTap: () {
          // INTERCEPT NAVIGATION: Route through the persistent Tab Wrapper instead of pushing a modal page
          final tabsScreen = MainTabsScreen.of(context);
          if (tabsScreen != null) {
            tabsScreen.navigateToLodgeDetails(lodge);
          } else {
            // Fallback just in case this card is ever rendered outside the Main Tabs Shell context
            debugPrint("MainTabsScreen ancestor not found. Falling back to default routing.");
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImageCard(
                  imageUrl: lodge.images.isNotEmpty ? lodge.images.first : null,
                  height: 190,
                  borderRadius: 14, 
                  placeholderIcon: Icons.hotel,
                  badges: cardBadges,
                ),

                if (!widget.isOwner)
                  Positioned(
                    bottom: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: AppIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      style: IconButtonStyle.filled,
                      backgroundColor: Colors.white,
                      color: isFavorite ? AppColors.error(context) : Colors.black54,
                      onTap: () => setState(() => isFavorite = !isFavorite),
                    ),
                  ),

                if (widget.isOwner)
                  Positioned(
                    top: 55,
                    right: AppSpacing.sm,
                    child: Column(
                      children: [
                        AppIconButton(
                          icon: Icons.meeting_room,
                          style: IconButtonStyle.filled,
                          backgroundColor: Colors.white,
                          color: AppColors.leafGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddRoomScreen(lodgeId: lodge.id),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppIconButton(
                          icon: Icons.edit,
                          style: IconButtonStyle.filled,
                          backgroundColor: Colors.white,
                          color: Colors.blue,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditLodgeScreen(lodge: lodge),
                              ),
                            );
                            if (result == true && mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppIconButton(
                          icon: Icons.delete,
                          style: IconButtonStyle.filled,
                          backgroundColor: Colors.white,
                          color: AppColors.error(context),
                          onTap: () => _showDeleteDialog(context),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          capitalizeText(lodge.name).toUpperCase(), 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (lodge.isVerified) ...[
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(
                          Icons.verified,
                          color: AppColors.leafGreen,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          "${capitalizeText(lodge.city)}, ${capitalizeText(lodge.district)}".toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
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
    );
  }
}