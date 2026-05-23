class Order {
  final int id;
  final String orderNumber;
  final int customerId;
  final int shopId;
  final String shopName;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double totalAmount;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final OrderDelivery? delivery;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.shopId,
    required this.shopName,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.totalAmount,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.delivery,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

  static int _toInt(dynamic v) =>
      v == null ? 0 : int.tryParse(v.toString()) ?? 0;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: _toInt(json['id']),
      orderNumber: json['order_number'] ?? '',
      customerId: _toInt(json['customer_id']),
      shopId: _toInt(json['shop']), // IMPORTANT: can be null
      shopName: json['shop_name'] ?? '',
      status: json['status'] ?? 'pending',

      subtotal: _toDouble(json['subtotal']),
      shippingFee: _toDouble(json['shipping_fee']),
      tax: _toDouble(json['tax']),
      totalAmount: _toDouble(json['total_amount']),

      deliveryAddress: json['delivery_address'] ?? '',

      deliveryLatitude: json['delivery_latitude'] == null
          ? null
          : _toDouble(json['delivery_latitude']),

      deliveryLongitude: json['delivery_longitude'] == null
          ? null
          : _toDouble(json['delivery_longitude']),

      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.tryParse(json['estimated_delivery_date'])
          : null,

      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.tryParse(json['actual_delivery_date'])
          : null,


      delivery: json['delivery'] != null
    ? OrderDelivery.fromJson(json['delivery'])
    : null,

      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],

      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),

      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ??
          DateTime.now(),
    );
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String productImage;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productImage,
  });

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    return OrderItem(
      id: _safeInt(json['id']),
      productId: _safeInt(product['id']),
      productName: product['name'] ?? '',
      quantity: _safeInt(json['quantity']),
      unitPrice: _safeDouble(json['unit_price']),
      totalPrice: _safeDouble(json['total_price']),
      productImage: product['image'] ?? '',
    );
  }
}


class OrderDelivery {
  final int id;
  final String status;
  final String? deliveryCode;
  final double? pickupLat;
  final double? pickupLng;
  final double? customerLat;
  final double? customerLng;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;

  OrderDelivery({
    required this.id,
    required this.status,
    this.deliveryCode,
    this.pickupLat,
    this.pickupLng,
    this.customerLat,
    this.customerLng,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
  });

factory OrderDelivery.fromJson(Map<String, dynamic> json) {
  final driver = json['delivery_person'] as Map<String, dynamic>?;

  return OrderDelivery(
    id: json['id'],
    status: json['status'] ?? '',
    deliveryCode: json['delivery_code'],

    pickupLat: json['pickup_latitude'] == null
        ? null
        : double.tryParse(json['pickup_latitude'].toString()),

    pickupLng: json['pickup_longitude'] == null
        ? null
        : double.tryParse(json['pickup_longitude'].toString()),

    customerLat: json['customer_latitude'] == null
        ? null
        : double.tryParse(json['customer_latitude'].toString()),

    customerLng: json['customer_longitude'] == null
        ? null
        : double.tryParse(json['customer_longitude'].toString()),

    deliveryPersonName: driver != null ? driver['full_name'] : null,
    deliveryPersonPhone: driver != null ? driver['phone_number'] : null,
  );
}
}