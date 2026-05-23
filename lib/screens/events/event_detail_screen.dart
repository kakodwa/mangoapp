// lib/screens/events/event_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../models/event_ticket_type_model.dart';

import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';
import 'buy_ticket_screen.dart';
import '../../theme/design_system/app_spacing.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {

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



    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(
        title: "Event Details",
      ),

      // =========================
      // FLOATING NAVIGATION BUTTON
      // =========================
      floatingActionButton:
    event.latitude != null && event.longitude != null
        ? FloatingActionButton(
            backgroundColor: AppColors.primary(context),
            child: Icon(Icons.navigation),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopMapModal(
                    shopLat: event.latitude!,
                    shopLng: event.longitude!,
                  ),
                ),
              );
            },
          )
        : null,

      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [

          // ======================
          // EVENT CARD
          // ======================

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ======================
                // IMAGE
                // ======================

                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),

                      child: Image.network(
                        event.banner,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,

                        errorBuilder:
                            (
                              context,
                              error,
                              stackTrace,
                            ) {
                          return Container(
                            height: 260,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),

                    if (event.isFeatured)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius:
                                BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: Text(
                            "FEATURED",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // ======================
                // CONTENT
                // ======================

                Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // TITLE
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // LOCATION
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),

                          const SizedBox(width: AppSpacing.xs),

                          Expanded(
                            child: Text(
                              "${event.venue}, ${event.city}",
                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // DATE + TIME
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),

                          const SizedBox(width: AppSpacing.xs),

                          Text(
                            event.eventDate,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .withOpacity(0.8),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "${event.startTime} - ${event.endTime}",
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ======================
                      // STATS
                      // ======================

                      // ======================
// STATS (UPDATED)
// ======================

Row(
  children: [

    // TOTAL TICKETS
    Expanded(
      child: statCard(
        title: "Tickets",
        value: totalSeats.toString(),
        icon: Icons.confirmation_num,
        context: context,
      ),
    ),

    const SizedBox(width: AppSpacing.sm),

    // AVAILABLE
    Expanded(
      child: statCard(
        title: "Available",
        value: availableSeats.toString(),
        icon: Icons.event_available,
        context: context,
      ),
    ),

    const SizedBox(width: AppSpacing.sm),

    // SOLD
    Expanded(
      child: statCard(
        title: "Sold",
        value: soldTickets.toString(),
        icon: Icons.people,
        context: context,
      ),
    ),
  ],
),

                      const SizedBox(height: AppSpacing.md),

                      // ======================
                      // PROGRESS
                      // ======================

                      LinearProgressIndicator(
                        value: soldPercentage,
                        minHeight: 8,

                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),

                        backgroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),

                        color: AppColors.primary(
                          context,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        "${(soldPercentage * 100).toStringAsFixed(0)}% tickets sold",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ======================
                      // TICKET TYPES
                      // ======================

                      Text(
                        "Available Tickets",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      ...event.ticketTypes.map(
                        (ticket) =>
                            ticketCard(context, ticket),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ======================
          // DESCRIPTION CARD
          // ======================

          Container(
            padding: EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  event.description,
                  style: TextStyle(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),

      // =========================
      // BUY TICKET BUTTON
      // =========================
      bottomNavigationBar: Container(
  padding: EdgeInsets.fromLTRB(16, 14, 16, 20),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.06),
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  ),
  child: SafeArea(
    top: false,
    child: SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(Icons.confirmation_num),
        label: Text(
          "Buy Ticket",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          foregroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        onPressed: () {
          if (event.ticketTypes.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No tickets available"),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BuyTicketScreen(
                event: event,
              ),
            ),
          );
        },
      ),
    ),
  ),
),
    );
  }

  // ======================
  // STAT CARD
  // ======================

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            size: 20,
            color: AppColors.primary(
              context,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            value,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: AppSpacing.xxs),

          Text(
            title,

            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ======================
  // TICKET CARD
  // ======================

  Widget ticketCard(
    BuildContext context,
    EventTicketTypeModel ticket,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),

      padding: EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Container(
            padding: EdgeInsets.all(AppSpacing.sm),

            decoration: BoxDecoration(
              color: AppColors.primary(
                context,
              ).withOpacity(.12),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              Icons.confirmation_num,
              color: AppColors.primary(
                context,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  ticket.name.toUpperCase(),

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxs),

                Text(
                  "${ticket.availableSeats} seats available",

                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          Text(
            "MWK ${ticket.price.toStringAsFixed(0)}",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,

              color: AppColors.primary(
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}