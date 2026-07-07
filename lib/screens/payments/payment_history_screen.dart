import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../theme/app_colors.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/web_footer.dart';

// Safe first-letter-only capitalization extension (Preserved)
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
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _allPayments.clear();
          _currentPage = 1;
          _hasMore = true;
          _isLoadingMore = false;
        });
        return ref.refresh(myPaymentsProvider);
      },
      child: paymentsAsync.when(
        data: (initialPayments) {
          // Sync Riverpod data into local state array on initial load
          if (_currentPage == 1 && _allPayments.isEmpty) {
            _allPayments.addAll(initialPayments);
            // If the initial response page returns fewer items than expected max capacity limits, 
            // assume it's the last page. Adjust this threshold number (e.g., 15 or 20) as needed.
            if (initialPayments.length < 15) {
              _hasMore = false;
            }
          }

          if (_allPayments.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "No payments found".toCapitalized(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const Spacer(),
                        const WebFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

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
                                            "MWK ${payment.amount}",
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
                      // childCount handles constraints properly inside SliverChildBuilderDelegate
                      childCount: _allPayments.length + (_isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
                const SliverToBoxAdapter(child: WebFooter()),
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
                    const WebFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle continuous data fetching
  Future<void> _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      
      // Update this call to match your actual API pagination parameters if required, 
      // e.g., ref.read(fetchMorePaymentsProvider(page: _currentPage))
      final newPayments = await ref.read(myPaymentsProvider.future); 

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          if (newPayments.isEmpty) {
            _hasMore = false;
          } else {
            _allPayments.addAll(newPayments);
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