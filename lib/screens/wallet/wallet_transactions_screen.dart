import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/wallet_provider.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/app_scaffold.dart';

class WalletTransactionsScreen extends ConsumerWidget {
  const WalletTransactionsScreen({super.key});

  /// Capitalizes only the first letter of a string and sets the rest to lowercase
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final lower = text.toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }

  String formatDate(String date) {
    return date.substring(0, 10);
  }

  String sectionTitle(String date) {
    final today = DateTime.now().toString().substring(0, 10);

    if (date == today) return "Today";
    return date;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(walletTransactionsProvider);

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          _capitalize('Wallet activity'),
          style: AppTypography.headlineMedium,
        ),
      ),
      body: txAsync.when(
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

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: grouped.entries.map((entry) {
              final date = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= DATE HEADER =================
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      _capitalize(sectionTitle(date)),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),

                  // ================= TRANSACTIONS =================
                  ...items.map((tx) {
                    final isCredit = tx.transactionType == "credit";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            // ICON Container
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

                            // DETAILS COLUMN
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(tx.source.replaceAll("_", " ")),
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                  if (tx.transactionRate > 0) ...[
                                    const SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      _capitalize("${tx.transactionRate}% platform fee applied"),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),

                            // AMOUNT & TIMESTAMP COLUMN
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${isCredit ? '+' : '-'} MWK ${tx.amount}",
                                  style: AppTypography.titleMedium.copyWith(
                                    color: getColor(context, tx.transactionType),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  _capitalize(tx.createdAt.substring(11, 16)),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
        loading: () => Center(
          child: AppLoader.inline(),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInfoBox(
              type: AppInfoType.error,
              message: _capitalize("Error: $e"),
            ),
          ),
        ),
      ),
    );
  }
}