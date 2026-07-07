class Order {
  final int id;
  final String orderNumber;
  final int customerId;
  final String customerName;

  final String status;

  final double subtotal;
  final double shippingFee;
  final double tax;
  final double totalAmount;

  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  final List<OrderItem> items;

  /// ⭐ NEW: MULTI SELLER SUPPORT
  final List<SellerOrder> sellerOrders;

  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.totalAmount,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.items,
    required this.sellerOrders,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      status: json['status'] ?? 'pending',

      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      shippingFee: double.tryParse(json['shipping_fee'].toString()) ?? 0,
      tax: double.tryParse(json['tax'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,

      deliveryAddress: json['delivery_address'] ?? '',
      deliveryLatitude: json['delivery_latitude'] == null
          ? null
          : double.tryParse(json['delivery_latitude'].toString()),
      deliveryLongitude: json['delivery_longitude'] == null
          ? null
          : double.tryParse(json['delivery_longitude'].toString()),

      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),

      sellerOrders: (json['seller_orders'] as List<dynamic>? ?? [])
          .map((e) => SellerOrder.fromJson(e))
          .toList(),

      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }
}

class SellerOrder {
  final int id;
  final int orderId;
  final int sellerId;

  final double subtotal;
  final double commission;
  final double sellerAmount;
  final double total;

  final String status;

  final String? deliveryCode;
  final String? deliveryStatus;

  final double? pickupLatitude;
  final double? pickupLongitude;

  final DateTime createdAt;

  SellerOrder({
    required this.id,
    required this.orderId,
    required this.sellerId,
    required this.subtotal,
    required this.commission,
    required this.sellerAmount,
    required this.total,
    required this.status,
    this.deliveryCode,
    this.deliveryStatus,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.createdAt,
  });

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    return SellerOrder(
      id: json['id'] ?? 0,
      orderId: json['order'] ?? 0,
      sellerId: json['seller'] ?? 0,

      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      commission: double.tryParse(json['commission'].toString()) ?? 0,
      sellerAmount:
          double.tryParse(json['seller_amount']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,

      status: json['status'] ?? 'pending',
      deliveryCode: json['delivery_code'],
      deliveryStatus: json['delivery_status'],

      pickupLatitude: json['pickup_latitude'] == null
          ? null
          : double.tryParse(json['pickup_latitude'].toString()),

      pickupLongitude: json['pickup_longitude'] == null
          ? null
          : double.tryParse(json['pickup_longitude'].toString()),

      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final Map<String, dynamic>? variantAttributes; // ✅ Added to capture variant properties mappings
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    this.variantAttributes, // ✅ Make choice context option properties optional
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    return OrderItem(
      id: json['id'] ?? 0,
      productId: product['id'] ?? 0,
      productName: json['product_name'] ?? product['name'] ?? '',
      productImage: json['product_image'] ?? product['image'] ?? '',
      // ✅ Dynamically check for attributes sent directly on item object root or under sub-variant keys
      variantAttributes: json['product_variant'] ?? json['variant_attributes'],
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
    );
  }
}