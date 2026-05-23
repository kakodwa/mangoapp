import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/wallet_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';

class WalletTransactionsScreen extends ConsumerWidget {
  const WalletTransactionsScreen({super.key});

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

  Color getColor(String type) {
    return type == "credit" ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(walletTransactionsProvider);

    return AppScaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,

      appBar: AppBar(
        title: const Text("Wallet Activity"),
        backgroundColor: AppColors.mangoOrange,
        elevation: 0,
      ),

      body: txAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text("No transactions yet"),
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
            padding: const EdgeInsets.all(AppSpacing.sm),
            children: grouped.entries.map((entry) {
              final date = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ================= DATE HEADER =================
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      sectionTitle(date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),

                  // ================= TRANSACTIONS =================
                  ...items.map((tx) {
                    final isCredit = tx.transactionType == "credit";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),

                      child: Row(
                        children: [

                          // ICON
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: getColor(tx.transactionType)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              getIcon(tx.source),
                              color: getColor(tx.transactionType),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          // DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  tx.source.replaceAll("_", " "),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xxs),

                                Text(
                                  tx.description,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xxs),

                                // 🔥 PLATFORM FEE TRANSPARENCY
                                if (tx.transactionRate > 0)
                                  Text(
                                    "${tx.transactionRate}% platform fee applied",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // AMOUNT
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [

                              Text(
                                "${isCredit ? '+' : '-'} MWK ${tx.amount}",
                                style: TextStyle(
                                  color: getColor(tx.transactionType),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxs),

                              Text(
                                tx.createdAt.substring(11, 16),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },

        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text("Error: $e"),
        ),
      ),
    );
  }
}