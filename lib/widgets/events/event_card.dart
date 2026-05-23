// lib/widgets/events/event_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../../screens/events/event_detail_screen.dart';
import '../../theme/app_colors.dart';

import '../../models/event_model.dart';
import '../../models/event_ticket_type_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {

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

    final soldPercentage = totalSeats == 0
        ? 0.0
        : soldTickets / totalSeats;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                event: event,
              ),
            ),
          );
        },
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
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    event.banner,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          context,
                          error,
                          stackTrace,
                        ) {
                      return Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // FEATURED BADGE
                if (event.isFeatured)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "FEATURED",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // PRICE BADGE
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.7),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Text(
                      "From MWK ${lowestPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // TITLE
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LOCATION
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color:
                            Colors.grey.shade600,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          "${event.venue}, ${event.city}",
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // DATE + TIME
                  Row(
                    children: [

                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color:
                            Colors.grey.shade600,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        formatDate(event.eventDate),
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "${formatTime(event.startTime)} - ${formatTime(event.endTime)}",
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

      
                  const SizedBox(height: 20),

                  // ======================
                  // BUTTON
                  // ======================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(
                              event: event,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                      ),
                      label: const Text(
                        "View Details",
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary(
                          context,
                        ),
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size(
                          double.infinity,
                          52,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
  // FORMAT DATE
  // ======================

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return DateFormat(
        "dd MMM yyyy",
      ).format(parsed);
    } catch (e) {
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
    } catch (e) {
      return time;
    }
  }
}