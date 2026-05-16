import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';
import '../../theme/app_colors.dart';

final userOrdersProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getList(
    'orders/',
    fromJson: (json) => Order.fromJson(json),
  );
});

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

  void _showDeliveryModal(BuildContext context, Order order) {
    final delivery = order.delivery;
    if (delivery == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "Delivery Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _infoTile("Delivery Code", delivery.deliveryCode ?? "-"),
                  _infoTile("Status", delivery.status),

                  const Divider(height: 24),

                  if ((delivery.deliveryPersonName ?? '').isNotEmpty) ...[
                    const Text(
                      "Rider",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _infoTile("Name", delivery.deliveryPersonName ?? "-"),
                    _infoTile("Phone", delivery.deliveryPersonPhone ?? "-"),
                    const Divider(height: 24),
                  ],

                  const Text(
                    "Tracking",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (delivery.pickupLat != null &&
                      delivery.pickupLng != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mangoOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.navigation),
                        label: const Text("Navigate to Rider"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShopMapModal(
                                shopLat: delivery.pickupLat!,
                                shopLng: delivery.pickupLng!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      appBar: const MainAppBar(title: 'My Orders'),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(userOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final isExpanded = expandedOrders.contains(order.id);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => toggleOrder(order.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order #${order.orderNumber}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(order.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[600],
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
                              )
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// STATUS + TOTAL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(order.status),
                                backgroundColor: AppColors.mangoLight
                                    .withOpacity(0.2),
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "MWK ${order.totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          /// EXPANDED
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            const Divider(),

                            const Text(
                              "Items",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            ...order.items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          item.productImage,
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${item.productName} x${item.quantity}",
                                        ),
                                      ),
                                      Text(
                                        "MWK ${item.totalPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                )),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Total: MWK ${order.totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if (order.delivery != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.mangoOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  icon: const Icon(Icons.local_shipping),
                                  label:
                                      const Text("View Delivery Details"),
                                  onPressed: () =>
                                      _showDeliveryModal(context, order),
                                ),
                              ),
                            ]
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text("Failed to load orders")),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year}";
}