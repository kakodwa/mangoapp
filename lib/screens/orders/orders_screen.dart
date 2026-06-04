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
import '../../widgets/app_scaffold.dart';

// First-letter capitalization extension string utility
extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

final userOrdersProvider = FutureProvider.autoDispose<List<Order>>(
  (ref) async {
    final apiClient = ref.watch(apiClientProvider);

    return apiClient.getList(
      'orders/',
      fromJson: (json) => Order.fromJson(json),
    );
  },
);

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final Set<int> expandedOrders = {};

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
    final ordersAsync = ref.watch(userOrdersProvider);

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'My orders'.toCapitalized(),
          style: AppTypography.headlineMedium,
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
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
              ref.refresh(userOrdersProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final order = orders[index];
                final isExpanded = expandedOrders.contains(order.id);

                return AppCard(
                  padding: EdgeInsets.zero, // explicit management via internal layout InkWell boundaries
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
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: AppLoader.inline(),
        ),
        error: (e, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInfoBox(
              type: AppInfoType.error,
              message: "Failed to load orders: ${e.toString()}".toCapitalized(),
            ),
          ),
        ),
      ),
    );
  }
}