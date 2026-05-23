// lib/screens/events/event_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/events_provider.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_filter_widgets.dart';
import '../../theme/design_system/app_spacing.dart';


class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() =>
      _EventListScreenState();
}

class _EventListScreenState
    extends ConsumerState<EventListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text("Events"),
      ),

      body: Column(
        children: [

          // ================= SEARCH =================
          UnifiedSearchBar(
            controller: _searchController,
            hintText: 'Search events...',
            onChanged: (_) => setState(() {}),
            onClear: () => setState(() {}),
          ),

          // ================= EVENTS =================
          Expanded(
            child: eventsAsync.when(
              data: (events) {

                // ================= FILTER =================
                final filteredEvents = events.where((event) {
                  final query = _searchController.text
                      .toLowerCase();

                  return event.title
                          .toLowerCase()
                          .contains(query) ||
                      event.description
                          .toLowerCase()
                          .contains(query) ||
                      event.venue
                          .toLowerCase()
                          .contains(query) ||
                      event.city
                          .toLowerCase()
                          .contains(query);
                }).toList();

                if (filteredEvents.isEmpty) {
                  return const Center(
                    child: Text("No events found"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(eventsProvider);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return EventCard(
                        event: filteredEvents[index],
                      );
                    },
                  ),
                );
              },

              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (e, _) => Center(
                child: Text(e.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
