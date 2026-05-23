class PaymentStatusModel {
  final String paymentReference;
  final String status;
  final String purpose;
  final double amount;

  PaymentStatusModel({
    required this.paymentReference,
    required this.status,
    required this.purpose,
    required this.amount,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      paymentReference: json['payment_reference'] ?? '',
      status: json['status'] ?? 'pending',
      purpose: json['purpose'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}