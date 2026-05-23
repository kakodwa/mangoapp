class BookingParams {
  final int roomId;
  final String checkInDate;
  final String checkOutDate;

  BookingParams({
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "room": roomId,
      "check_in_date": checkInDate,
      "check_out_date": checkOutDate,
    };
  }
}