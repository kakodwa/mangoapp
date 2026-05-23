import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/api_provider.dart';
import '../../models/availability_model.dart';

final availabilityProvider = FutureProvider.family<
    AvailabilityModel,
    int>((ref, roomId) async {
  final api = ref.watch(apiClientProvider);

  return api.get(
    'rooms/$roomId/availability/',
    fromJson: (json) => AvailabilityModel.fromJson(json),
  );
});

class AvailabilityCalendar extends ConsumerStatefulWidget {
  final int roomId;

  const AvailabilityCalendar({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<AvailabilityCalendar> createState() =>
      _AvailabilityCalendarState();
}

class _AvailabilityCalendarState
    extends ConsumerState<AvailabilityCalendar> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  bool isBooked(DateTime day, List<DateTime> bookedDates) {
    final d = DateTime(day.year, day.month, day.day);

    return bookedDates.any((b) {
      final bd = DateTime(b.year, b.month, b.day);
      return bd == d;
    });
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final availabilityAsync =
        ref.watch(availabilityProvider(widget.roomId));

    return availabilityAsync.when(
      data: (availability) {
        return Column(
          children: [
            /// ================= LEGEND =================
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _legend(Colors.green, "Available"),
                  _legend(Colors.red, "Booked"),
                ],
              ),
            ),

            /// ================= CALENDAR =================
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(
                const Duration(days: 365),
              ),
              focusedDay: focusedDay,

              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },

              onDaySelected: (selected, focused) {
                if (isBooked(selected, availability.bookedDates)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("This room is already booked"),
                    ),
                  );
                  return;
                }

                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              enabledDayPredicate: (day) {
                return !isBooked(day, availability.bookedDates);
              },

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final booked =
                      isBooked(day, availability.bookedDates);

                  if (booked) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return null;
                },
              ),

              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),

                selectedDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },

      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      error: (e, _) => Center(
        child: Text(e.toString()),
      ),
    );
  }
}