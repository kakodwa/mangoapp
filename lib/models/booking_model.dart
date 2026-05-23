class Booking {
  final int id;
  final String bookingReference;
  final String checkInDate;
  final String checkOutDate;
  final String bookingStatus;
  final String paymentStatus;
  final double totalAmount;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.totalAmount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingReference: json['booking_reference'] ?? '',
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      bookingStatus: json['booking_status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      totalAmount:
          double.tryParse(json['total_amount'].toString()) ?? 0,
    );
  }
}