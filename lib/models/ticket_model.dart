class TicketItemModel {
  final String ticketTypeName;
  final int quantity;
  final double subtotal;

  TicketItemModel({
    required this.ticketTypeName,
    required this.quantity,
    required this.subtotal,
  });

  factory TicketItemModel.fromJson(Map<String, dynamic> json) {
    return TicketItemModel(
      ticketTypeName: json['ticket_type_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
    );
  }
}



class TicketModel {
  final int id;
  final String ticketNumber;

  final int? eventId;
  final String eventTitle;

  final List<TicketItemModel> items;

  final String? seatNumber;

  final String? customerName;

  final int quantity;
  final double totalAmount;
  final String paymentStatus;

  final String? qrCodeUrl;
  final String? purchasedAt;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    this.eventId,
    required this.eventTitle,
    required this.items,
    this.seatNumber,
    this.customerName,
    required this.quantity,
    required this.totalAmount,
    required this.paymentStatus,
    this.qrCodeUrl,
    this.purchasedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      eventId: json['event'] is int
    ? json['event']
    : json['event'] is Map
        ? json['event']['id']
        : int.tryParse(json['event'].toString()),
      eventTitle: json['event_title'] ?? '',

      items: (json['items'] as List? ?? [])
          .map((e) => TicketItemModel.fromJson(e))
          .toList(),

      seatNumber: json['seat_number'],
      customerName: json['customer_name'],
      quantity: json['quantity'] ?? 1,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'pending',
      qrCodeUrl: json['qr_code'],
      purchasedAt: json['purchased_at'],
    );
  }
}