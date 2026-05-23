import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../providers/tickets_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';

class EventTicketsScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventTicketsScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventTicketsScreen> createState() =>
      _EventTicketsScreenState();
}

class _EventTicketsScreenState
    extends ConsumerState<EventTicketsScreen> {

  final TextEditingController _searchController =
      TextEditingController();

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {

    final ticketsAsync = ref.watch(
      eventTicketsProvider(widget.event.id),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: AppColors.darkText,
        title: const Text(
          "Sold Tickets",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ticketsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(error.toString()),
          ),
        ),

        data: (allTickets) {

          // ================= SEARCH FILTER =================

          final tickets = allTickets.where((ticket) {

            final query = searchQuery.toLowerCase();

            final customer =
                ticket.customerName?.toLowerCase() ?? '';

            final ticketNo =
                ticket.ticketNumber.toLowerCase();

            final eventTitle =
                ticket.eventTitle.toLowerCase();

            return customer.contains(query) ||
                ticketNo.contains(query) ||
                eventTitle.contains(query);

          }).toList();

          // ================= TOTALS =================

          final totalRevenue = tickets.fold<double>(
            0,
            (sum, t) => sum + t.totalAmount,
          );

          final totalTickets = tickets.fold<int>(
            0,
            (sum, t) => sum + t.quantity,
          );

          final Map<String, int> breakdown = {};

          for (final ticket in tickets) {
            for (final item in ticket.items) {
              breakdown[item.ticketTypeName] =
                  (breakdown[item.ticketTypeName] ?? 0) +
                      item.quantity;
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(
                eventTicketsProvider(widget.event.id).future,
              );
            },

            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.only(bottom: 30),

              child: Column(
                children: [

                  // ================= HEADER =================

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mangoOrange,
                          AppColors.mangoLight,
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mangoOrange
                              .withOpacity(.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          widget.event.title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        Text(
                          "${widget.event.venue}, ${widget.event.city}",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [

                            Expanded(
                              child: _summaryCard(
                                "Tickets",
                                totalTickets.toString(),
                                Icons.confirmation_number,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.sm),

                            Expanded(
                              child: _summaryCard(
                                "Revenue",
                                "MWK ${totalRevenue.toStringAsFixed(0)}",
                                Icons.payments,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ================= SEARCH =================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child: TextField(
                      controller: _searchController,

                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },

                      decoration: InputDecoration(
                        hintText:
                            "Search customer or ticket number",

                        prefixIcon:
                            const Icon(Icons.search),

                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,

                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 0,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ================= BREAKDOWN =================

                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(22),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Ticket Breakdown",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        if (tickets.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Text(
                              "No tickets sold yet",
                            ),
                          ),

                        ...breakdown.entries.map((e) {

                          return Container(
                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            padding:
                                const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.circular(
                                      14),
                            ),

                            child: Row(
                              children: [

                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      AppColors
                                          .mangoOrange
                                          .withOpacity(.1),

                                  child: Icon(
                                    Icons.local_activity,
                                    color: AppColors
                                        .mangoOrange,
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(width: AppSpacing.sm),

                                Expanded(
                                  child: Text(
                                    e.key,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),

                                Text(
                                  "${e.value} sold",
                                  style: TextStyle(
                                    color: AppColors
                                        .mangoOrange,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ================= TICKETS =================

                  if (tickets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "No tickets found",
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: tickets.length,
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      padding: const EdgeInsets.all(AppSpacing.md),

                      itemBuilder: (context, i) {

                        final ticket = tickets[i];

                        return Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 14,
                          ),

                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(
                                    24),

                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withOpacity(.04),
                                blurRadius: 12,
                                offset:
                                    const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding:
                                const EdgeInsets.all(18),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(
                                  children: [

                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .all(14),

                                      decoration:
                                          BoxDecoration(
                                        color: AppColors
                                            .mangoOrange
                                            .withOpacity(
                                                .1),

                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    16),
                                      ),

                                      child: Icon(
                                        Icons
                                            .confirmation_number,
                                        color: AppColors
                                            .mangoOrange,
                                      ),
                                    ),

                                    const SizedBox(
                                        width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                          Text(
                                            ticket
                                                .ticketNumber,
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 16,
                                            ),
                                          ),

                                          const SizedBox(
                                              height: 4),

                                          Text(
                                            ticket
                                                    .customerName ??
                                                "Customer",
                                            style:
                                                TextStyle(
                                              color: Colors
                                                  .grey
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),

                                      decoration:
                                          BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary
                                            .withOpacity(
                                                .1),

                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    30),
                                      ),

                                      child: Text(
                                        "PAID",
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).colorScheme.secondary,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Container(
                                  padding:
                                      const EdgeInsets.all(
                                          14),

                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.outline.withOpacity(0.05),
                                    borderRadius:
                                        BorderRadius
                                            .circular(16),
                                  ),

                                  child: Column(
                                    children: [

                                      Row(
                                        children: [

                                          const Icon(
                                            Icons.payments,
                                            size: 18,
                                          ),

                                          const SizedBox(
                                              width: 8),

                                          Text(
                                            "MWK ${ticket.totalAmount.toStringAsFixed(0)}",
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                          height: 14),

                                      ...ticket.items
                                          .map((item) {

                                        return Padding(
                                          padding:
                                              const EdgeInsets
                                                  .only(
                                            bottom: 8,
                                          ),

                                          child: Row(
                                            children: [

                                              Expanded(
                                                child: Text(
                                                  item
                                                      .ticketTypeName,
                                                ),
                                              ),

                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical: 5,
                                                ),

                                                decoration:
                                                    BoxDecoration(
                                                  color: AppColors
                                                      .mangoOrange
                                                      .withOpacity(
                                                          .1),

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),

                                                child: Text(
                                                  "x${item.quantity}",
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        AppColors.mangoOrange,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: Theme.of(context).colorScheme.surface,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}