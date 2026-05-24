class Booking {
  final int id;
  final String bookingReference;

  final String checkInDate;
  final String checkOutDate;

  final String bookingStatus;
  final String paymentStatus;

  final double totalAmount;
  final String? qrCode;

  final int totalNights;

  final String lodgeName;

  final String roomName;
  final String roomNumber;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.totalAmount,
    this.qrCode,
    required this.totalNights,
    required this.lodgeName,
    required this.roomName,
    required this.roomNumber,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,

      bookingReference:
          json['booking_reference'] ?? '',

      checkInDate:
          json['check_in_date'] ?? '',

      checkOutDate:
          json['check_out_date'] ?? '',

      bookingStatus:
          json['booking_status'] ?? '',

      paymentStatus:
          json['payment_status'] ?? '',

      totalAmount:
          double.tryParse(
                json['total_amount'].toString(),
              ) ??
              0,

      qrCode: json['qr_code'],

      totalNights:
          json['total_nights'] ?? 0,

      lodgeName:
          json['lodge_name'] ?? '',

      roomName:
          json['room_name'] ?? '',

      roomNumber:
          json['room_number'] ?? '',
    );
  }
}