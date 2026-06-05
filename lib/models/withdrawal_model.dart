// lib/models/withdrawal_model.dart

class WithdrawalModel {
  final int id;
  final String amount;
  final String status;
  final String payoutMethod;
  final String accountHolderName;
  final String accountNumber;
  final String? bankName;
  final String? bankBranch;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String rejectionReason;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.payoutMethod,
    required this.accountHolderName,
    required this.accountNumber,
    this.bankName,
    this.bankBranch,
    required this.requestedAt,
    this.processedAt,
    required this.rejectionReason,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'],
      amount: json['amount'].toString(),
      status: json['status'] ?? 'pending',
      payoutMethod: json['payout_method'] ?? 'mobile_money',
      accountHolderName: json['account_holder_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      bankName: json['bank_name'],
      bankBranch: json['bank_branch'],
      requestedAt: DateTime.parse(json['requested_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      rejectionReason: json['rejection_reason'] ?? '',
    );
  }
}