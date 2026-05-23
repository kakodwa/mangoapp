class AvailabilityModel {
  final List<DateTime> bookedDates;

  AvailabilityModel({
    required this.bookedDates,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      bookedDates: (json['booked_dates'] as List)
          .map((e) => DateTime.parse(e))
          .toList(),
    );
  }
}