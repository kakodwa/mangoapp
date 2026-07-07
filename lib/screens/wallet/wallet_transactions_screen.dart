import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/wallet_provider.dart';

import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

import '../../widgets/web_footer.dart';

class WalletTransactionsScreen extends ConsumerStatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  ConsumerState<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState
    extends ConsumerState<WalletTransactionsScreen> {
  final ScrollController _controller = ScrollController();

  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels >
          _controller.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    _page++;

    try {
      // ⚠️ IMPORTANT:
      // You must update your provider to accept page parameter.
      final newData =
          await ref.refresh(walletTransactionsProvider.future);

      if (newData.isEmpty) {
        _hasMore = false;
      }
    } catch (_) {
      _hasMore = false;
    }

    setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final lower = text.toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }

  String formatDate(String date) => date.substring(0, 10);

  String sectionTitle(String date) {
    final today = DateTime.now().toString().substring(0, 10);
    return date == today ? "Today" : date;
  }

  IconData getIcon(String source) {
    switch (source) {
      case "order_payment":
        return Icons.shopping_bag;
      case "property_unlock":
        return Icons.home;
      case "withdrawal":
        return Icons.arrow_upward;
      case "bonus":
        return Icons.card_giftcard;
      default:
        return Icons.swap_horiz;
    }
  }

  Color getColor(BuildContext context, String type) {
    return type == "credit"
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(walletTransactionsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return txAsync.when(
      loading: () => Center(child: AppLoader.inline()),

      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppInfoBox(
            type: AppInfoType.error,
            message: _capitalize("Error: $e"),
          ),
        ),
      ),

      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppInfoBox(
                type: AppInfoType.info,
                message: _capitalize("No transactions yet"),
              ),
            ),
          );
        }

        // GROUP BY DATE
        final Map<String, List> grouped = {};
        for (var tx in transactions) {
          final date = formatDate(tx.createdAt);
          grouped.putIfAbsent(date, () => []);
          grouped[date]!.add(tx);
        }

        // FLATTEN LIST
        final List items = [];
        grouped.forEach((date, txs) {
          items.add({"type": "header", "date": date});
          for (var tx in txs) {
            items.add({"type": "tx", "data": tx});
          }
        });

        return CustomScrollView(
          controller: _controller,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal:
                    isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md,
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
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Center(
                          child: _isLoadingMore
                              ? const CircularProgressIndicator()
                              : const SizedBox.shrink(),
                        ),
                      );
                    }

                    final item = items[index];

                    // ================= HEADER =================
                    if (item["type"] == "header") {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs),
                        child: Text(
                          _capitalize(sectionTitle(item["date"])),
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      );
                    }

                    // ================= ITEM =================
                    final tx = item["data"];
                    final isCredit = tx.transactionType == "credit";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: getColor(context, tx.transactionType)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                getIcon(tx.source),
                                color: getColor(context, tx.transactionType),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(
                                        tx.source.replaceAll("_", " ")),
                                    style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    _capitalize(tx.description),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${isCredit ? '+' : '-'} MWK ${tx.amount}",
                                  style: AppTypography.titleMedium.copyWith(
                                    color: getColor(
                                        context, tx.transactionType),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  tx.createdAt.substring(11, 16),
                                  style: AppTypography.labelSmall.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: items.length + 1,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(child: WebFooter()),
          ],
        );
      },
    );
  }
}