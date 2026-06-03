// lib/widgets/events/event_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/event_model.dart';
import '../../screens/events/event_detail_screen.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_spacing.dart';

class EventCard extends StatefulWidget {
  final EventModel event;

  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    // ======================
    // LOWEST TICKET PRICE
    // ======================

    double lowestPrice = 0;

    if (event.ticketTypes.isNotEmpty) {
      lowestPrice = event.ticketTypes
          .map((e) => e.price)
          .reduce((a, b) => a < b ? a : b);
    }

    // ======================
    // TOTAL / AVAILABLE
    // ======================

    final totalSeats = event.ticketTypes.fold<int>(
      0,
      (sum, item) => sum + item.totalSeats,
    );

    final availableSeats = event.ticketTypes.fold<int>(
      0,
      (sum, item) => sum + item.availableSeats,
    );

    final soldTickets = totalSeats - availableSeats;

    final soldPercentage =
        totalSeats == 0 ? 0.0 : soldTickets / totalSeats;

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
            pageBuilder: (_, __, ___) => EventDetailScreen(
              event: event,
            ),
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
                        child: Image.network(
                          event.banner,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.25),
                              child: const Icon(
                                Icons.event,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // GRADIENT OVERLAY

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.05),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.45),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // BADGES

                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Row(
                      children: [
  if (event.isFeatured)
    const AppBadge(
      text: "FEATURED",
      type: BadgeType.warning,
      fontSize: 9,
    ),

  const Spacer(),

  AppBadge(
    text: "MWK ${lowestPrice.toStringAsFixed(0)}",
    type: BadgeType.success,
    fontSize: 9,
  ),
],
                    ),
                  ),

                  // EVENT DATE CHIP

                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Text(
                        formatDate(event.eventDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ================= INFO =================

              Padding(
                padding:
                    const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // TITLE

                    Text(
                      event.title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    // LOCATION

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.65),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${event.venue}, ${event.city}",
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                          context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(
                                          0.65),
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    // TIME + TICKETS

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.65),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${formatTime(event.startTime)} - ${formatTime(event.endTime)}",
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                          context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(
                                          0.65),
                                ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          Icons.confirmation_num,
                          size: 14,
                          color: Colors.green,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          "$availableSeats left",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    // SALES PROGRESS

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child:
                          LinearProgressIndicator(
                        value: soldPercentage,
                        minHeight: 6,
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Text(
                          "$soldTickets sold",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          "$totalSeats total",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall,
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

  // ======================
  // FORMAT DATE
  // ======================

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return DateFormat(
        "dd MMM yyyy",
      ).format(parsed);
    } catch (_) {
      return date;
    }
  }

  // ======================
  // FORMAT TIME
  // ======================

  String formatTime(String time) {
    try {
      final parts = time.split(":");

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final dt = DateTime(
        0,
        0,
        0,
        hour,
        minute,
      );

      return DateFormat.jm().format(dt);
    } catch (_) {
      return time;
    }
  }
}