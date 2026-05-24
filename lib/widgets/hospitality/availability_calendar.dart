import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/api_provider.dart';
import '../../models/availability_model.dart';
import '../../models/room_model.dart';

final roomProvider = FutureProvider.family<Room, int>((ref, roomId) async {
  final api = ref.watch(apiClientProvider);
  return api.get('rooms/$roomId/', fromJson: (j) => Room.fromJson(j));
});

final availabilityProvider =
    FutureProvider.family<AvailabilityModel, int>((ref, roomId) async {
  final api = ref.watch(apiClientProvider);
  return api.get(
    'rooms/$roomId/availability/',
    fromJson: (j) => AvailabilityModel.fromJson(j),
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

  DateTime? rangeStart;
  DateTime? rangeEnd;

  // ================= BOOKED CHECK =================
  bool isBooked(DateTime day, Set<String> bookedSet) {
    final key = DateTime(day.year, day.month, day.day)
        .toIso8601String()
        .split('T')
        .first;

    return bookedSet.contains(key);
  }

  // ================= RANGE CHECK =================
  bool isInRange(DateTime day) {
    if (rangeStart == null) return false;

    final start = rangeStart!;
    final end = rangeEnd ?? rangeStart!;

    return day.isAtSameMomentAs(start) ||
        day.isAtSameMomentAs(end) ||
        (day.isAfter(start) && day.isBefore(end));
  }

  // ================= RANGE LOGIC =================
  void _onDaySelected(
    DateTime selected,
    DateTime focused,
    Set<String> bookedSet,
  ) {
    bool booked(DateTime d) {
      final key = DateTime(d.year, d.month, d.day)
          .toIso8601String()
          .split('T')
          .first;

      return bookedSet.contains(key);
    }

    setState(() {
      focusedDay = focused;

      // RESET WHEN RANGE ALREADY COMPLETE
      if (rangeStart != null && rangeEnd != null) {
        rangeStart = selected;
        rangeEnd = null;
        return;
      }

      rangeStart ??= selected;

      // START OVER IF SELECTED BEFORE START
      if (selected.isBefore(rangeStart!)) {
        rangeStart = selected;
        rangeEnd = null;
        return;
      }

      // STOP RANGE WHEN HITTING BOOKED DATE
      DateTime cursor = rangeStart!;
      DateTime? lastValid;

      while (!cursor.isAfter(selected)) {
        if (booked(cursor)) {
          break;
        }

        lastValid = cursor;
        cursor = cursor.add(const Duration(days: 1));
      }

      rangeEnd = lastValid;
    });
  }

  // ================= PRICE =================
  int getNights() {
    if (rangeStart == null || rangeEnd == null) return 0;

    return rangeEnd!.difference(rangeStart!).inDays;
  }

  int totalPrice(double pricePerNight) {
    return getNights() * pricePerNight.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomProvider(widget.roomId));

    final availabilityAsync =
        ref.watch(availabilityProvider(widget.roomId));

    return roomAsync.when(
      data: (room) {
        return availabilityAsync.when(
          data: (availability) {
            final bookedSet = availability.bookedDates
                .map(
                  (d) => DateTime(d.year, d.month, d.day)
                      .toIso8601String()
                      .split('T')
                      .first,
                )
                .toSet();

            final nights = getNights();
            final total = totalPrice(room.pricePerNight);

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ================= LEGEND =================
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: const [
                        _Legend(
                          color: Colors.white,
                          text: "Available",
                        ),
                        _Legend(
                          color: Colors.orange,
                          text: "Booked",
                        ),
                        _Legend(
                          color: Colors.blue,
                          text: "Selected",
                        ),
                      ],
                    ),
                  ),

                  // ================= PRICE SUMMARY =================
                  if (rangeStart != null && rangeEnd != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$nights nights = MWK $total",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // ================= CALENDAR =================
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay:
                        DateTime.now().add(const Duration(days: 365)),
                    focusedDay: focusedDay,

                    selectedDayPredicate: (day) =>
                        isSameDay(rangeStart, day) ||
                        isSameDay(rangeEnd, day),

                    onDaySelected: (selected, focused) =>
                        _onDaySelected(
                      selected,
                      focused,
                      bookedSet,
                    ),

                    // BOOKED DAYS NOT CLICKABLE
                    enabledDayPredicate: (day) =>
                        !isBooked(day, bookedSet),

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder:
                          (context, day, focusedDay) {
                        final booked =
                            isBooked(day, bookedSet);

                        final inRange = isInRange(day);

                        if (booked) {
                          return _bookedCell(day);
                        }

                        if (inRange) {
                          return _rangeCell(day);
                        }

                        return _availableCell(day);
                      },

                      selectedBuilder:
                          (context, day, focusedDay) {
                        final booked =
                            isBooked(day, bookedSet);

                        return booked
                            ? _bookedCell(day)
                            : _rangeCell(day);
                      },

                      disabledBuilder:
                          (context, day, focusedDay) {
                        return _bookedCell(day);
                      },
                    ),

                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(e.toString())),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(e.toString())),
    );
  }

  // ================= UI: BOOKED =================
  Widget _bookedCell(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= UI: AVAILABLE =================
  Widget _availableCell(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      alignment: Alignment.center,
      child: Text('${day.day}'),
    );
  }

  // ================= UI: RANGE =================
  Widget _rangeCell(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ================= LEGEND =================
class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: Colors.black12,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}