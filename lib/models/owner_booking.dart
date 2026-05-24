class OwnerBooking {
  final int id;
  final String bookingReference;
  final String customerName;
  final String lodgeName;
  final String roomNumber;
  final String roomName;
  final String checkInDate;
  final String checkOutDate;
  final int totalNights;
  final double totalAmount;
  final String bookingStatus;
  final String? qrCode;

  OwnerBooking({
    required this.id,
    required this.bookingReference,
    required this.customerName,
    required this.lodgeName,
    required this.roomNumber,
    required this.roomName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.totalAmount,
    required this.bookingStatus,
    this.qrCode,
  });

  factory OwnerBooking.fromJson(Map<String, dynamic> json) {
    return OwnerBooking(
      id: json['id'],
      bookingReference: json['booking_reference'] ?? '',
      customerName: json['customer_name'] ?? '',
      lodgeName: json['lodge_name'] ?? '',
      roomNumber: json['room_number'] ?? '',
      roomName: json['room_name'] ?? '',
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      totalNights: json['total_nights'] ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      bookingStatus: json['booking_status'] ?? '',
      qrCode: json['qr_code'],
    );
  }
}