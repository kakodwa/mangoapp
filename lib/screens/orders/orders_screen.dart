import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< HEAD
import '../../models/order_model.dart';
import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';

final userOrdersProvider =
    FutureProvider.autoDispose<List<Order>>(
  (ref) async {
    final apiClient =
        ref.watch(apiClientProvider);

    return apiClient.getList(
      'orders/',
      fromJson: (json) =>
          Order.fromJson(json),
    );
  },
);

class OrdersScreen
    extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key})
      : super(key: key);

  @override
  ConsumerState<OrdersScreen>
      createState() =>
          _OrdersScreenState();
}

class _OrdersScreenState
    extends ConsumerState<OrdersScreen> {
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  final Set<int> expandedOrders = {};

  void toggleOrder(int orderId) {
    setState(() {
      expandedOrders.contains(orderId)
<<<<<<< HEAD
          ? expandedOrders.remove(
              orderId,
            )
=======
          ? expandedOrders.remove(orderId)
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          : expandedOrders.add(orderId);
    });
  }

<<<<<<< HEAD
  // ======================
  // DELIVERY MODAL
  // ======================

  void _showDeliveryModal(
    BuildContext context,
    Order order,
  ) {
    final delivery = order.delivery;

=======
  void _showDeliveryModal(BuildContext context, Order order) {
    final delivery = order.delivery;
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    if (delivery == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
<<<<<<< HEAD
      backgroundColor:
          Colors.transparent,
      builder: (_) {
        return Container(
          padding:
              const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey
                              .shade300,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Center(
                      child: Text(
                        "Delivery Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .all(16),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey
                            .shade50,
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),
                      child: Column(
                        children: [
                          _infoTile(
                            Icons.qr_code,
                            "Delivery Code",
                            delivery
                                    .deliveryCode ??
                                "-",
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          _infoTile(
                            Icons
                                .local_shipping,
                            "Status",
                            delivery.status,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    if ((delivery
                                .deliveryPersonName ??
                            '')
                        .isNotEmpty) ...[
                      const Text(
                        "Rider Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .all(16),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey
                              .shade50,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                        child: Column(
                          children: [
                            _infoTile(
                              Icons.person,
                              "Name",
                              delivery
                                      .deliveryPersonName ??
                                  "-",
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            _infoTile(
                              Icons.phone,
                              "Phone",
                              delivery
                                      .deliveryPersonPhone ??
                                  "-",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],

                    if (delivery.pickupLat !=
                            null &&
                        delivery.pickupLng !=
                            null)
                      SizedBox(
                        width:
                            double.infinity,
                        height: 54,
                        child:
                            ElevatedButton.icon(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                AppColors
                                    .mangoOrange,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.navigation,
                          ),
                          label: const Text(
                            "Navigate to Rider",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ShopMapModal(
                                  shopLat: delivery
                                      .pickupLat!,
                                  shopLng: delivery
                                      .pickupLng!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(
                      height: 14,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        style:
                            OutlinedButton
                                .styleFrom(
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(
                          context,
                        ),
                        child: const Text(
                          "Close",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          ),
        );
      },
    );
  }

<<<<<<< HEAD
  // ======================
  // INFO TILE
  // ======================

  Widget _infoTile(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.mangoLight
                .withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.mangoOrange,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    final ordersAsync =
        ref.watch(userOrdersProvider);

    return AppScaffold(
      appBar: const MainAppBar(
        title: 'My Orders',
      ),

      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Container(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                margin:
                    const EdgeInsets.all(
                  24,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.04,
                      ),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .shopping_bag_outlined,
                      size: 80,
                      color:
                          Colors.grey[400],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      "No orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      "Your placed orders will appear here",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors
                            .grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(
                userOrdersProvider,
              );
            },

            child: ListView.separated(
              padding:
                  const EdgeInsets.all(
                16,
              ),

              itemCount: orders.length,

              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 14,
              ),

              itemBuilder:
                  (context, index) {
                final order =
                    orders[index];

                final isExpanded =
                    expandedOrders
                        .contains(
                  order.id,
                );

                return AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          0.04,
                        ),
                        blurRadius: 12,
                        offset:
                            const Offset(
                          0,
                          5,
                        ),
                      ),
                    ],
                  ),

                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                    onTap: () =>
                        toggleOrder(
                      order.id,
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(18),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          // ======================
                          // HEADER
                          // ======================

                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      AppColors
                                          .mangoLight
                                          .withOpacity(
                                    0.18,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                child:
                                    Icon(
                                  Icons
                                      .receipt_long,
                                  color:
                                      AppColors
                                          .mangoOrange,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      "Order #${order.orderNumber}",
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            16,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                          4,
                                    ),

                                    Text(
                                      _formatDate(
                                        order
                                            .createdAt,
                                      ),
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.grey.shade600,
                                        fontSize:
                                            12,
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                                      ),
                                    ),
                                  ],
                                ),
                              ),
<<<<<<< HEAD

                              Icon(
                                isExpanded
                                    ? Icons
                                        .keyboard_arrow_up
                                    : Icons
                                        .keyboard_arrow_down,
                                color:
                                    AppColors
                                        .mangoOrange,
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ======================
                          // STATUS + TOTAL
                          // ======================

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      14,
                                  vertical:
                                      8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: AppColors
                                      .mangoLight
                                      .withOpacity(
                                    0.18,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    30,
                                  ),
                                ),
                                child: Text(
                                  order.status
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ),

                              Text(
                                "MWK ${order.totalAmount.toStringAsFixed(2)}",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      16,
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                                ),
                              ),
                            ],
                          ),

<<<<<<< HEAD
                          // ======================
                          // EXPANDED
                          // ======================

                          if (isExpanded) ...[
                            const SizedBox(
                              height: 18,
                            ),

                            Divider(
                              color: Colors
                                  .grey
                                  .shade200,
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            const Text(
                              "Order Items",
                              style:
                                  TextStyle(
                                fontSize:
                                    15,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            ...order.items.map(
                              (item) {
                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom:
                                        12,
                                  ),

                                  padding:
                                      const EdgeInsets.all(
                                    12,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .grey
                                        .shade50,
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),

                                  child:
                                      Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
                                        child:
                                            Image.network(
                                          item
                                              .productImage,
                                          width:
                                              55,
                                          height:
                                              55,
                                          fit: BoxFit
                                              .cover,
                                          errorBuilder:
                                              (
                                            _,
                                            __,
                                            ___,
                                          ) =>
                                                  Container(
                                            width:
                                                55,
                                            height:
                                                55,
                                            color:
                                                Colors.grey.shade200,
                                            child:
                                                const Icon(
                                              Icons.image,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            12,
                                      ),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  4,
                                            ),

                                            Text(
                                              "Quantity: ${item.quantity}",
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.grey.shade600,
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        "MWK ${item.totalPrice.toStringAsFixed(2)}",
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Align(
                              alignment:
                                  Alignment
                                      .centerRight,
                              child: Text(
                                "Total: MWK ${order.totalAmount.toStringAsFixed(2)}",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      15,
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                                ),
                              ),
                            ),

<<<<<<< HEAD
                            if (order.delivery !=
                                null) ...[
                              const SizedBox(
                                height: 18,
                              ),

                              SizedBox(
                                width: double
                                    .infinity,
                                height: 52,
                                child:
                                    ElevatedButton.icon(
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.mangoOrange,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                  ),
                                  icon:
                                      const Icon(
                                    Icons
                                        .local_shipping,
                                  ),
                                  label:
                                      const Text(
                                    "View Delivery Details",
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _showDeliveryModal(
                                    context,
                                    order,
                                  ),
                                ),
                              ),
                            ],
                          ],
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
<<<<<<< HEAD

        loading: () => const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (_, __) => Center(
          child: Container(
            padding:
                const EdgeInsets.all(24),
            margin:
                const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 70,
                  color: Colors.red[300],
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(
                  "Failed to load orders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
=======
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text("Failed to load orders")),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      ),
    );
  }

<<<<<<< HEAD
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
=======
  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year}";
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
}