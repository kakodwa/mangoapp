class EventTicketTypeModel {
  final int id;
  final String name; // regular, vip, vvip
  final double price;
  final int totalSeats;
  final int availableSeats;

  EventTicketTypeModel({
    required this.id,
    required this.name,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
  });

  factory EventTicketTypeModel.fromJson(Map<String, dynamic> json) {
    return EventTicketTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
    };
  }
}