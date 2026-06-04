// lib/screens/events/manage_events_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/event_model.dart';
import '../../models/event_ticket_type_model.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_fab.dart';
import 'event_tickets_screen.dart';
import 'create_event_screen.dart';
import '../../theme/design_system/app_spacing.dart';

class ManageEventsScreen extends ConsumerStatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  ConsumerState<ManageEventsScreen> createState() =>
      _ManageEventsScreenState();
}

class _ManageEventsScreenState
    extends ConsumerState<ManageEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================
  // HELPERS
  // =========================

  int getTotalTickets(EventModel event) {
    return event.ticketTypes.fold(
      0,
      (sum, type) => sum + type.totalSeats,
    );
  }

  int getAvailableTickets(EventModel event) {
    return event.ticketTypes.fold(
      0,
      (sum, type) => sum + type.availableSeats,
    );
  }

  int getSoldTickets(EventModel event) {
    return getTotalTickets(event) -
        getAvailableTickets(event);
  }

  double getRevenue(EventModel event) {
    double revenue = 0;

    for (final type in event.ticketTypes) {
      final sold =
          type.totalSeats - type.availableSeats;

      revenue += sold * type.price;
    }

    return revenue;
  }

  // =========================
  // EVENT CARD
  // =========================

  Widget buildEventCard(EventModel event) {
    final totalTickets = getTotalTickets(event);

    final availableTickets =
        getAvailableTickets(event);

    final soldTickets = getSoldTickets(event);

    final revenue = getRevenue(event);

    final soldPercentage =
        totalTickets == 0
            ? 0.0
            : soldTickets / totalTickets;

    return Container(
      margin: EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
                  top: Radius.circular(22),
                ),
                child: Image.network(
                  event.banner,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      height: 210,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                      ),
                    );
                  },
                ),
              ),

              Container(
                height: 210,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 18,
                bottom: 18,
                right: 18,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.surface,
                          size: 18,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            "${event.venue}, ${event.city}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (event.isFeatured)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mangoOrange,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Text(
                      "FEATURED",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ======================
                // DATE
                // ======================

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18,
                      color: AppColors.mangoOrange,
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    Text(
                      event.eventDate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "${event.startTime} - ${event.endTime}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // ======================
                // TICKET TYPES
                // ======================

                Text(
                  "Ticket Types",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: event.ticketTypes
                      .map(
                        (type) =>
                            buildTicketTypeChip(type),
                      )
                      .toList(),
                ),

                const SizedBox(height: 22),

                // ======================
                // STATS
                // ======================

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        title: "Total",
                        value:
                            totalTickets.toString(),
                        icon:
                            Icons.confirmation_num,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: statCard(
                        title: "Sold",
                        value:
                            soldTickets.toString(),
                        icon: Icons.sell,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: statCard(
                        title: "Revenue",
                        value:
                            "MWK ${revenue.toStringAsFixed(0)}",
                        icon:
                            Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: soldPercentage,
                    minHeight: 10,
                    backgroundColor:
                        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                    valueColor:
                        AlwaysStoppedAnimation(
                      AppColors.leafGreen,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  "${(soldPercentage * 100).toStringAsFixed(0)}% sold • $availableTickets remaining",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.qr_code_scanner,
                        ),
                        label: Text(
                          "Check-ins",
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(0, 52),
                          foregroundColor:
                              AppColors.mangoOrange,
                          side: BorderSide(
                            color:
                                AppColors.mangoOrange,
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

                    const SizedBox(width: 14),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventTicketsScreen(event: event),
                              ),
                            );
                          },
                        icon: Icon(
                          Icons.settings,
                        ),
                        label:
                            Text("Manage"),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.mangoOrange,
                          foregroundColor:
                              Theme.of(context).colorScheme.surface,
                          minimumSize:
                              const Size(0, 52),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TICKET TYPE CHIP
  // =========================

  Widget buildTicketTypeChip(
    EventTicketTypeModel type,
  ) {
    final sold =
        type.totalSeats - type.availableSeats;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.mangoOrange.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              AppColors.mangoOrange.withOpacity(.2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.name,
            style: TextStyle(
              color: AppColors.mangoOrange,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "MWK ${type.price.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.xxs),

          Text(
            "$sold sold • ${type.availableSeats} left",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STAT CARD
  // =========================

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.mangoOrange,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(
      myEventsProvider,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Manage Event'),),


      floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 50),
  child: AppFab(
    heroTag: "add_event",
    icon: Icons.add,
    tooltip: "Add Event",
    toastMessage: "Create event",
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEventScreen(),
        ),
      );
    },
  ),
),

      body: eventsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text("No events found"),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return buildEventCard(
                events[index],
              );
            },
          );
        },
      ),
    );
  }
}