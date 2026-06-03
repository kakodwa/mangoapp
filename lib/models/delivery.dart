class Escrow {
  final double amount;
  final String status;

  Escrow({required this.amount, required this.status});

  factory Escrow.fromJson(Map<String, dynamic> json) {
    return Escrow(
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      status: json['status'] ?? '',
    );
  }
}



class DeliveryPerson {
  final String fullName;
  final String phoneNumber;
  final String vehicleNumber;
  final String vehicleType;

  DeliveryPerson({
    required this.fullName,
    required this.phoneNumber,
    required this.vehicleNumber,
    required this.vehicleType,
  });

  factory DeliveryPerson.fromJson(Map<String, dynamic> json) {
    return DeliveryPerson(
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
    );
  }
}



class Delivery {
  final int id;
  final String status;
  final String orderNumber;

  final String? deliveryCode;
  final String? customerDeliveryCode;

  final double? pickupLat;
  final double? pickupLng;
  final double? customerLat;
  final double? customerLng;

  final String? address;
  final String? phone;

  final List<dynamic>? items;

  final DeliveryPerson? rider;
  final List<Escrow>? escrow;

  Delivery({
    required this.id,
    required this.status,
    required this.orderNumber,
    this.deliveryCode,
    this.customerDeliveryCode,
    this.pickupLat,
    this.pickupLng,
    this.customerLat,
    this.customerLng,
    this.address,
    this.phone,
    this.items,
    this.rider,
    this.escrow,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      status: json['status'] ?? '',
      orderNumber: json['order_number'] ?? '',
      deliveryCode: json['delivery_code'],
      customerDeliveryCode: json['customer_delivery_code'],

      pickupLat: json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString())
          : null,

      pickupLng: json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString())
          : null,

      customerLat: json['customer_latitude'] != null
          ? double.tryParse(json['customer_latitude'].toString())
          : null,

      customerLng: json['customer_longitude'] != null
          ? double.tryParse(json['customer_longitude'].toString())
          : null,

      address: json['delivery_address'],
      phone: json['delivery_phone_number'],

      items: json['items'] ?? [],

      rider: json['delivery_person'] != null
          ? DeliveryPerson.fromJson(json['delivery_person'])
          : null,

      escrow: json['escrow'] != null
          ? (json['escrow'] as List)
              .map((e) => Escrow.fromJson(e))
              .toList()
          : [],
    );
  }
}