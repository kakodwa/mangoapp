// lib/screens/wallet/payout_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/withdrawal_model.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/web_footer.dart';

class PayoutHistoryScreen extends ConsumerStatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  ConsumerState<PayoutHistoryScreen> createState() =>
      _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends ConsumerState<PayoutHistoryScreen> {
  final ScrollController _controller = ScrollController();

  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels >
          _controller.position.maxScrollExtent - 250) {
        _loadMore();
      }
    });
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    _page++;

    try {
      // ⚠️ Currently refreshes full list (until backend paging exists)
      final data =
          await ref.refresh(historicalWithdrawalsProvider.future);

      if (data.isEmpty) {
        _hasMore = false;
      }
    } catch (_) {
      _hasMore = false;
    }

    setState(() => _isLoadingMore = false);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalsAsync = ref.watch(historicalWithdrawalsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        _hasMore = true;
        ref.refresh(historicalWithdrawalsProvider);
      },
      child: withdrawalsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),

        error: (err, __) => Center(
          child: Text('Failed to load transaction history: $err'),
        ),

        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'No cashout requests found.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            );
          }

          // ================= FLATTEN (for lazy rendering) =================
          final List items = [];
          for (var item in list) {
            items.add(item);
          }

          return CustomScrollView(
            controller: _controller,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal:
                      isLargeScreen ? (screenWidth - 800) / 2 : 12.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // ================= FOOTER LOADER =================
                      if (index == items.length) {
                        if (!_hasMore) {
                          return const SizedBox(height: 80);
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: _isLoadingMore
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final item = items[index] as WithdrawalModel;

                      return _buildWithdrawalCard(item);
                    },
                    childCount: items.length + 1,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
              const SliverToBoxAdapter(child: WebFooter()),
            ],
          );
        },
      ),
    );
  }

  // ================= CARD UI =================
  Widget _buildWithdrawalCard(WithdrawalModel item) {
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(item.requestedAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AMOUNT + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MWK ${item.amount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

            // METHOD
            Row(
              children: [
                Icon(
                  item.payoutMethod == 'mobile_money'
                      ? Icons.phone_android
                      : Icons.account_balance,
                  size: 16,
                  color: AppColors.mangoOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.payoutMethod == 'mobile_money'
                        ? 'Mobile Money: ${item.accountNumber}'
                        : '${item.bankName} - ${item.accountNumber}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            // REJECTION REASON
            if (item.status == 'rejected' &&
                item.rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${item.rejectionReason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade900,
                        ),
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

  // ================= STATUS BADGE =================
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
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}