// lib/screens/payment/payment_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/web_footer.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../utils/price_helper.dart';

extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final List<PaymentModel> _allPayments = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // 🔑 Auto-refresh payment provider whenever the screen is opened
    Future.microtask(() {
      _resetLocalState();
      ref.invalidate(myPaymentsProvider);
    });
  }

  void _resetLocalState() {
    _allPayments.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    // Sync state whenever provider fetches new data
    ref.listen<AsyncValue<List<PaymentModel>>>(myPaymentsProvider, (previous, next) {
      next.whenData((payments) {
        if (mounted) {
          setState(() {
            _allPayments.clear();
            _allPayments.addAll(payments);
            if (payments.length < 15) {
              _hasMore = false;
            }
          });
        }
      });
    });

    final paymentsAsync = ref.watch(myPaymentsProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    return RefreshIndicator(
      onRefresh: () async {
        _resetLocalState();
        return ref.refresh(myPaymentsProvider.future);
      },
      child: paymentsAsync.when(
        data: (initialPayments) {
          // Sync data into local state if empty
          if (_currentPage == 1 && _allPayments.isEmpty) {
            _allPayments.addAll(initialPayments);
            if (initialPayments.length < 15) {
              _hasMore = false;
            }
          }

          // ================= CENTERED RECTANGLE EMPTY STATE =================
          if (_allPayments.isEmpty) {
            return CustomScrollView(
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
                              "No Payments Found",
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              "Your completed and pending payment receipts will be displayed here once transactions are recorded.",
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
                const SliverToBoxAdapter(
                  child: WebFooter(),
                ),
              ],
            );
          }

          // ================= PAYMENT LIST =================
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isLoadingMore && _hasMore && 
                  scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
                _loadMoreData();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                    horizontal: isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.sm,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == _allPayments.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Center(child: AppLoader.inline()),
                          );
                        }

                        final payment = _allPayments[index];
                        final bool isCompleted = payment.status == "completed";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: AppCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isCompleted ? Icons.check_circle : Icons.pending,
                                      color: isCompleted ? Colors.green : Colors.orange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            formatWithCommas(payment.amount),
                                            style: AppTypography.titleLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            payment.purposeDisplay.toCapitalized(),
                                            style: AppTypography.bodyMedium,
                                          ),
                                          Text(
                                            payment.paymentMethodDisplay.toCapitalized(),
                                            style: AppTypography.bodySmall.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (payment.orderNumber != null) ...[
                                            const SizedBox(height: AppSpacing.xxs),
                                            Text(
                                              "Order: ${payment.orderNumber}".toCapitalized(),
                                              style: AppTypography.bodySmall,
                                            ),
                                          ],
                                          if (payment.propertyTitle != null) ...[
                                            const SizedBox(height: AppSpacing.xxs),
                                            Text(
                                              payment.propertyTitle!.toCapitalized(),
                                              style: AppTypography.bodySmall,
                                            ),
                                          ],
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            payment.paymentReference.toCapitalized(),
                                            style: AppTypography.labelSmall.copyWith(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    AppBadge(
                                      text: payment.statusDisplay.toCapitalized(),
                                      type: isCompleted ? BadgeType.success : BadgeType.warning,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _allPayments.length + (_isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: WebFooter(),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: AppLoader.inline(),
        ),
        error: (e, _) => CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Icon(Icons.signal_wifi_connected_no_internet_4, size: 64, color: Colors.grey),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No internet connection or server unreachable.\nPull down to try again.',
                      textAlign: TextAlign.center,
                      style: AppTypography.titleMedium.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Error: ${e.toString()}".toCapitalized(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade400),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: WebFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final newPayments = await ref.read(myPaymentsProvider.future);

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          if (newPayments.isEmpty) {
            _hasMore = false;
          } else {
            for (var p in newPayments) {
              if (!_allPayments.any((existing) => existing.id == p.id)) {
                _allPayments.add(p);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }
}