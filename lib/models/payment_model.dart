class PaymentModel {
  final int id;
  final String paymentReference;
  final double amount;

  final String purpose;
  final String purposeDisplay;

  final String paymentMethod;
  final String paymentMethodDisplay;

  final String status;
  final String statusDisplay;

  final String? orderNumber;
  final String? propertyTitle;

  final String createdAt;

  PaymentModel({
    required this.id,
    required this.paymentReference,
    required this.amount,
    required this.purpose,
    required this.purposeDisplay,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
    required this.status,
    required this.statusDisplay,
    this.orderNumber,
    this.propertyTitle,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],

      paymentReference: json['payment_reference'] ?? '',

   

      amount: double.tryParse(
  json['amount'].toString(),
) ?? 0.0,

      purpose: json['purpose'] ?? '',
      purposeDisplay: json['purpose_display'] ?? '',

      paymentMethod: json['payment_method'] ?? '',
      paymentMethodDisplay:
          json['payment_method_display'] ?? '',

      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',

      orderNumber: json['order_number'],

      propertyTitle: json['property_title'],

      createdAt: json['created_at'] ?? '',
    );
  }
}