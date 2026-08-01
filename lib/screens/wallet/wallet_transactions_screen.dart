// lib/screens/wallet/wallet_transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (!_controller.hasClients) return;
      final maxScroll = _controller.position.maxScrollExtent;
      final currentScroll = _controller.position.pixels;

      if (currentScroll >= maxScroll - 250) {
        ref.read(walletTransactionsProvider.notifier).fetchNextPage();
      }
    });
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

  String formatDate(String date) {
    if (date.length >= 10) {
      return date.substring(0, 10);
    }
    return date;
  }

  String sectionTitle(String date) {
    final today = DateTime.now().toString().substring(0, 10);
    return date == today ? "Today" : date;
  }

  IconData getIcon(String source) {
    switch (source.toLowerCase()) {
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
    return type.toLowerCase() == "credit"
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletTransactionsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    // 1. Initial Loading
    if (state.isLoading && state.transactions.isEmpty) {
      return Center(child: AppLoader.inline());
    }

    // 2. Unauthenticated / Error View
    if (state.errorMessage != null && state.transactions.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppInfoBox(
                      type: AppInfoType.error,
                      message: state.errorMessage!,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (state.isUnauthenticated) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } else {
                          ref
                              .read(walletTransactionsProvider.notifier)
                              .fetchFirstPage();
                        }
                      },
                      icon: Icon(state.isUnauthenticated
                          ? Icons.login
                          : Icons.refresh),
                      label: Text(state.isUnauthenticated ? "Log In" : "Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mangoOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: WebFooter()),
        ],
      );
    }

    // 3. Compact Centered Rectangle Empty State Card
    if (state.transactions.isEmpty && !state.isLoading) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(walletTransactionsProvider.notifier)
              .fetchFirstPage();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.mangoOrange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 26,
                            color: AppColors.mangoOrange,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "No Transactions Yet",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          "Your wallet history and transaction details will appear here once you start purchasing or withdrawing.",
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: WebFooter()),
          ],
        ),
      );
    }

    // 4. Populate grouped items
    final Map<String, List> grouped = {};
    for (var tx in state.transactions) {
      final date = formatDate(tx.createdAt);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(tx);
    }

    final List items = [];
    grouped.forEach((date, txs) {
      items.add({"type": "header", "date": date});
      for (var tx in txs) {
        items.add({"type": "tx", "data": tx});
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(walletTransactionsProvider.notifier)
            .fetchFirstPage();
      },
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: isLargeScreen
                  ? (screenWidth - 800) / 2
                  : AppSpacing.md,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == items.length) {
                    if (!state.hasMore) {
                      return const SizedBox(height: 20);
                    }

                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: state.isMoreLoading
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.mangoOrange,
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }

                  final item = items[index];

                  // Header Row
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

                  // Transaction Row
                  final tx = item["data"];
                  final isCredit = tx.transactionType.toLowerCase() == "credit";

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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  _capitalize(tx.description ?? ""),
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
                                tx.createdAt.length >= 16
                                    ? tx.createdAt.substring(11, 16)
                                    : "",
                                style: AppTypography.labelSmall.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline,
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
          const SliverToBoxAdapter(
            child: WebFooter(),
          ),
        ],
      ),
    );
  }
}