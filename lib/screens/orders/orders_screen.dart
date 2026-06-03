import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_model.dart';
import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/design_system/app_spacing.dart';

final userOrdersProvider =
    FutureProvider.autoDispose<List<Order>>(
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "MWK ${item.totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.w700),
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
      appBar: const MainAppBar(title: 'My Orders'),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(userOrdersProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = orders[index];
                final isExpanded = expandedOrders.contains(order.id);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => toggleOrder(order.id),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
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
                                  color: AppColors.mangoLight.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: AppColors.mangoOrange,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order #${order.orderNumber}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(order.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.mangoOrange,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ================= TOTAL =================
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mangoLight.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  order.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                "MWK ${order.totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          // ================= EXPANDED =================
                          if (isExpanded) ...[
                            const SizedBox(height: 18),
                            Divider(color: Colors.grey.withOpacity(0.25)),
                            const SizedBox(height: 12),

                            const Text(
                              "Order Items",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ================= ITEMS (GLOBAL) =================
                            ...order.items.map(_buildItem).toList(),

                            const SizedBox(height: 20),

                            // ================= SELLER BREAKDOWN =================
                            const Text(
                              "Seller Breakdown",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 12),

                            ...order.sellerOrders.map((sellerOrder) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
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
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Seller #${sellerOrder.sellerId}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          sellerOrder.status.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Text(
                                      "Subtotal: MWK ${sellerOrder.subtotal.toStringAsFixed(2)}",
                                    ),
                                    Text(
                                      "Commission: MWK ${sellerOrder.commission.toStringAsFixed(2)}",
                                    ),
                                    Text(
                                      "To Seller: MWK ${sellerOrder.sellerAmount.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Delivery: ${sellerOrder.deliveryStatus ?? 'pending'}",
                                      style: const TextStyle(
                                        fontSize: 12,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text("Failed to load orders")),
      ),
    );
  }
}