// lib/widgets/events/event_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/event_model.dart';
import '../../screens/events/event_detail_screen.dart';

import '../../widgets/capitalize_text.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_image_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_spacing.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    double lowestPrice = 0;
    if (event.ticketTypes.isNotEmpty) {
      lowestPrice = event.ticketTypes
          .map((e) => e.price)
          .reduce((a, b) => a < b ? a : b);
    }

    final totalSeats = event.ticketTypes.fold<int>(
      0,
      (sum, item) => sum + item.totalSeats,
    );

    final availableSeats = event.ticketTypes.fold<int>(
      0,
      (sum, item) => sum + item.availableSeats,
    );

    final soldTickets = totalSeats - availableSeats;
    final soldPercentage = totalSeats == 0 ? 0.0 : soldTickets / totalSeats;

    final subTextColor = Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withOpacity(0.65);

    return Padding(
      // UPDATED: Set left and right padding to 2.0
      padding: const EdgeInsets.only(
        left: 2.0,
        right: 2.0,
        bottom: AppSpacing.sm,
      ),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 250),
              pageBuilder: (_, __, ___) => EventDetailScreen(event: event),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.95, end: 1.0).animate(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppImageCard(
                imageUrl: event.banner,
                height: double.infinity,
                borderRadius: 14,
                placeholderIcon: Icons.event,
                overlay: Stack(
                  children: [
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(event.eventDate).toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                badges: [
                  if (event.isFeatured)
                    const AppBadge(
                      text: "FEATURED",
                      type: BadgeType.warning,
                      fontSize: 9,
                    )
                  else
                    const SizedBox.shrink(),
                    
                  AppBadge(
                    text: "MWK ${lowestPrice.toStringAsFixed(0)}",
                    type: BadgeType.success,
                    fontSize: 9,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    capitalizeText(event.title).toUpperCase(), // UPDATED: Transformed to UPPERCASE
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: subTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${capitalizeText(event.venue)}, ${capitalizeText(event.city)}".toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: subTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: subTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}".toUpperCase(), // UPDATED: Transformed to UPPERCASE
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: subTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.confirmation_num,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$availableSeats left".toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: soldPercentage,
                      minHeight: 6,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.08),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "$soldTickets sold".toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$totalSeats total".toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.4,
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

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy").format(parsed);
    } catch (_) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final dt = DateTime(0, 0, 0, hour, minute);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return time;
    }
  }
}