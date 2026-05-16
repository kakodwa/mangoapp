class Wallet {
  final double balance;
  final String currency;
  final double totalEarnings;
  final double totalWithdrawn;

  Wallet({
    required this.balance,
    required this.currency,
    required this.totalEarnings,
    required this.totalWithdrawn,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'MWK',
      totalEarnings: double.tryParse(json['total_earnings'].toString()) ?? 0.0,
      totalWithdrawn: double.tryParse(json['total_withdrawn'].toString()) ?? 0.0,
    );
  }
}



class WalletTransaction {
  final String transactionType;
  final String source;
  final double amount;
  final double transactionRate;
  final double balanceBefore;
  final double balanceAfter;
  final String? reference;
  final String description;
  final String createdAt;

  WalletTransaction({
    required this.transactionType,
    required this.source,
    required this.amount,
    required this.transactionRate,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.reference,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      transactionType: json['transaction_type'] ?? '',
      source: json['source'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,

      
      transactionRate:
          double.tryParse(json['transaction_rate']?.toString() ?? '0') ?? 0.0,

      balanceBefore:
          double.tryParse(json['balance_before'].toString()) ?? 0.0,

      balanceAfter:
          double.tryParse(json['balance_after'].toString()) ?? 0.0,

      reference: json['reference'],
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}