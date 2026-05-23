// lib/screens/events/event_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../models/event_ticket_type_model.dart';

import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';
import 'buy_ticket_screen.dart';

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
      backgroundColor: Colors.grey.shade100,

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
            child: const Icon(Icons.navigation),
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
        padding: const EdgeInsets.all(16),
        children: [

          // ======================
          // EVENT CARD
          // ======================

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
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
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(
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
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius:
                                BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: const Text(
                            "FEATURED",
                            style: TextStyle(
                              color: Colors.white,
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
                  padding: const EdgeInsets.all(18),
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
                                Colors.grey.shade600,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              "${event.venue}, ${event.city}",
                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade700,
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
                                Colors.grey.shade600,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            event.eventDate,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade700,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "${event.startTime} - ${event.endTime}",
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade700,
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

    const SizedBox(width: 12),

    // AVAILABLE
    Expanded(
      child: statCard(
        title: "Available",
        value: availableSeats.toString(),
        icon: Icons.event_available,
        context: context,
      ),
    ),

    const SizedBox(width: 12),

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

                      const SizedBox(height: 20),

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
                            Colors.grey.shade200,

                        color: AppColors.primary(
                          context,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${(soldPercentage * 100).toStringAsFixed(0)}% tickets sold",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ======================
                      // TICKET TYPES
                      // ======================

                      const Text(
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
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
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
                    color: Colors.grey.shade800,
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
  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.06),
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
        icon: const Icon(Icons.confirmation_num),
        label: const Text(
          "Buy Ticket",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          foregroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

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

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,

            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
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
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(12),

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

                const SizedBox(height: 4),

                Text(
                  "${ticket.availableSeats} seats available",

                  style: TextStyle(
                    color: Colors.grey.shade700,
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