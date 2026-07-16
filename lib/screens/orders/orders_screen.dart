// lib/screens/orders/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_model.dart';
import '../../providers/api_provider.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/web_footer.dart';

extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

// State container to bundle paginated order lists cleanly
class OrdersPaginationState {
  final List<Order> orders;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;

  const OrdersPaginationState({
    required this.orders,
    required this.isLoading,
    required this.hasMore,
    this.errorMessage,
  });

  OrdersPaginationState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
  }) {
    return OrdersPaginationState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

// Managed auto-pagination controller provider
class OrdersNotifier extends AutoDisposeNotifier<OrdersPaginationState> {
  int _currentPage = 1;

  @override
  OrdersPaginationState build() {
    // Initial fetch trigger
    Future.microtask(() => fetchNextPage());
    return const OrdersPaginationState(
      orders: [],
      isLoading: false,
      hasMore: true,
    );
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final apiClient = ref.read(apiClientProvider);

      // Append pagination query parameters dynamically
      final fetchedOrders = await apiClient.getList(
        'orders/?page=$_currentPage',
        fromJson: (json) => Order.fromJson(json),
      );

      if (fetchedOrders.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
      } else {
        _currentPage++;
        state = state.copyWith(
          orders: [...state.orders, ...fetchedOrders],
          isLoading: false,
          hasMore: fetchedOrders.length >= 10, // Adjust threshold matching backend limits
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    state = const OrdersPaginationState(
      orders: [],
      isLoading: false,
      hasMore: true,
    );
    await fetchNextPage();
  }
}

final ordersPaginationProvider =
    NotifierProvider.autoDispose<OrdersNotifier, OrdersPaginationState>(() {
  return OrdersNotifier();
});

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> expandedOrders = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger infinite fetch when nearing bottom threshold bounds
    if (currentScroll >= maxScroll - 250) {
      ref.read(ordersPaginationProvider.notifier).fetchNextPage();
    }
  }

  void toggleOrder(int orderId) {
    setState(() {
      expandedOrders.contains(orderId)
          ? expandedOrders.remove(orderId)
          : expandedOrders.add(orderId);
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildItem(OrderItem item) {
    final variantText = item.variantAttributes != null && item.variantAttributes!.isNotEmpty
        ? item.variantAttributes!.entries.map((e) => "${e.key}: ${e.value}").join(", ")
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.productImage,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 55,
                height: 55,
                color: Colors.grey.withOpacity(0.2),
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.toCapitalized(),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variantText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    variantText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  "Qty: ${item.quantity}".toCapitalized(),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "MWK ${item.totalPrice.toStringAsFixed(2)}".toCapitalized(),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(ordersPaginationProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    final double edgePadding = isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md;

    // Error UI fallback block
    if (paginationState.orders.isEmpty && paginationState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppInfoBox(
            type: AppInfoType.error,
            message: "Failed to load orders: ${paginationState.errorMessage}".toCapitalized(),
          ),
        ),
      );
    }

    // Empty state fallback block
    if (paginationState.orders.isEmpty && !paginationState.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppInfoBox(
            type: AppInfoType.info,
            message: "No orders yet".toCapitalized(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ordersPaginationProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Infinite Responsive Orders List Grid/Sliver
          SliverPadding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: edgePadding,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = paginationState.orders[index];
                  final isExpanded = expandedOrders.contains(order.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => toggleOrder(order.id),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ================= HEADER =================
                                  Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Order #${order.orderNumber}".toCapitalized(),
                                              style: AppTypography.titleLarge.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: AppSpacing.xxs),
                                            Text(
                                              _formatDate(order.createdAt).toCapitalized(),
                                              style: AppTypography.bodySmall.copyWith(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: AppSpacing.md),

                                  // ================= TOTAL & BADGE =================
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppBadge(
                                        text: order.status.toCapitalized(),
                                        type: order.status.toLowerCase() == 'completed'
                                            ? BadgeType.success
                                            : BadgeType.warning,
                                      ),
                                      Text(
                                        "MWK ${order.totalAmount.toStringAsFixed(2)}",
                                        style: AppTypography.titleLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // ================= EXPANDED ITEMS SECTION =================
                                  if (isExpanded) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Divider(color: Colors.grey.withOpacity(0.25)),
                                    const SizedBox(height: AppSpacing.sm),

                                    Text(
                                      "Order items".toCapitalized(),
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),

                                    // ================= ITEMS (GLOBAL) =================
                                    ...order.items.map(_buildItem).toList(),

                                    const SizedBox(height: AppSpacing.md),

                                    // ================= SELLER BREAKDOWN =================
                                    Text(
                                      "Seller breakdown".toCapitalized(),
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),

                                    ...order.sellerOrders.map((sellerOrder) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.store, size: 18),
                                                const SizedBox(width: AppSpacing.xs),
                                                Expanded(
                                                  child: Text(
                                                    "Seller #${sellerOrder.sellerId}".toCapitalized(),
                                                    style: AppTypography.titleSmall.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  sellerOrder.status.toCapitalized(),
                                                  style: AppTypography.labelSmall.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSpacing.xs),
                                            Text(
                                              "Subtotal: MWK ${sellerOrder.subtotal.toStringAsFixed(2)}",
                                              style: AppTypography.bodyMedium,
                                            ),
                                            Text(
                                              "Commission: MWK ${sellerOrder.commission.toStringAsFixed(2)}".toCapitalized(),
                                              style: AppTypography.bodyMedium,
                                            ),
                                            Text(
                                              "To seller: MWK ${sellerOrder.sellerAmount.toStringAsFixed(2)}".toCapitalized(),
                                              style: AppTypography.bodyMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: AppSpacing.xxs),
                                            Text(
                                              "Delivery: ${sellerOrder.deliveryStatus ?? 'pending'}".toCapitalized(),
                                              style: AppTypography.bodySmall.copyWith(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: paginationState.orders.length,
              ),
            ),
          ),

          // Dynamic loading inline indicator element
          if (paginationState.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: AppLoader.inline()),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          const SliverToBoxAdapter(child: WebFooter()),
        ],
      ),
    );
  }
}