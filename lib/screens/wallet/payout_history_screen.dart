// lib/screens/wallet/payout_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Run 'flutter pub add intl' for date formating
import '../../models/withdrawal_model.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';

class PayoutHistoryScreen extends ConsumerWidget {
  const PayoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(historicalWithdrawalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal History'),
        backgroundColor: const Color(0xFFF5F7FA),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(historicalWithdrawalsProvider),
        child: withdrawalsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'No cashout requests found.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return _buildWithdrawalCard(item);
              },
            );
          },
          loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.mangoOrange),
              ),
          error: (err, __) => Center(
                child: Text('Failed to load transaction history: $err'),
              ),
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard(WithdrawalModel item) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.requestedAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MWK ${item.amount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Icon(
                  item.payoutMethod == 'mobile_money' ? Icons.phone_android : Icons.account_balance,
                  size: 16,
                  color: AppColors.mangoOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.payoutMethod == 'mobile_money'
                        ? 'Mobile Money: ${item.accountNumber}'
                        : '${item.bankName} - ${item.accountNumber}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (item.status == 'rejected' && item.rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${item.rejectionReason}',
                        style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'processed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Completed';
        break;
      case 'approved':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Approved';
        break;
      case 'rejected':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Failed';
        break;
      default:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Processing';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}