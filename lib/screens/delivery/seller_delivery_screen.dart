import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';
import '../../widgets/shop_map_modal.dart';
import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';

// ============================
// DELIVERY MODEL (UPDATED)
// ============================
class Delivery {
  final int id;
  final String status;
  final String orderNumber;
  final String? deliveryCode;

  final double? pickupLat;
  final double? pickupLng;

  final double? customerLat;
  final double? customerLng;

  final String? address;
  final String? phone;

  final List<dynamic>? items;

  Delivery({
    required this.id,
    required this.status,
    required this.orderNumber,
    this.deliveryCode,
    this.pickupLat,
    this.pickupLng,
    this.customerLat,
    this.customerLng,
    this.address,
    this.phone,
    this.items,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      status: json['status'] ?? '',
      orderNumber: json['order_number'] ?? '',
      deliveryCode: json['delivery_code'],
      pickupLat: json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString())
          : null,
      pickupLng: json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString())
          : null,
      customerLat: json['customer_latitude'] != null
          ? double.tryParse(json['customer_latitude'].toString())
          : null,
      customerLng: json['customer_longitude'] != null
          ? double.tryParse(json['customer_longitude'].toString())
          : null,
      address: json['delivery_address'],
      phone: json['delivery_phone_number'],
      items: json['items'],
    );
  }
}
// ============================
// PROVIDER
// ============================
final sellerDeliveriesProvider =
    FutureProvider.autoDispose<List<Delivery>>((ref) async {
  final api = ref.watch(apiClientProvider);

  return api.getList(
    'deliveries/',
    fromJson: (json) => Delivery.fromJson(json),
  );
});

// ============================
// SCREEN
// ============================
class SellerDeliveryScreen extends ConsumerWidget {
  const SellerDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(sellerDeliveriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary(context),
        title: Text(
          "Seller Deliveries",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        centerTitle: true,
      ),

      body: deliveriesAsync.when(
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 70,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "No deliveries yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final d = deliveries[index];

              return Container(
                margin: EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // =========================
                      // HEADER
                      // =========================
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary(context)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: AppColors.primary(context),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order #${d.orderNumber}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text(context),
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xxs),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.leafGreen
                                        .withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    d.status.toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.leafGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // DETAILS
                      // =========================
                      _infoTile(
                        context: context,
                        icon: Icons.phone,
                        label: "Phone",
                        value: d.phone ?? "-",
                      ),

                      const SizedBox(height: 10),

                      _infoTile(
                        context: context,
                        icon: Icons.location_on_outlined,
                        label: "Address",
                        value: d.address ?? "-",
                      ),

                      const SizedBox(height: AppSpacing.md),



                      // =========================
                      // ITEMS
                      // =========================
                      if (d.items != null && d.items!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    color:
                                        AppColors.primary(context),
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    "Items to Deliver",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 15,
                                      color:
                                          AppColors.text(context),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              ...d.items!.map(
                                (item) => Padding(
                                  padding:
                                      EdgeInsets.only(
                                    bottom: 6,
                                  ),
                                  child: Text(
                                    "• ${item['product_name']} x${item['quantity']}  •  MWK ${item['total_price']}",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSpacing.md),

                        // ================= DELIVERY CODE =================
                    if (d.deliveryCode != null)
                      DeliveryCodeCard(code: d.deliveryCode!),

                      // =========================
                      // BUTTONS
                      // =========================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.person_add_alt_1),
                          label: Text("Assign Rider"),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                AppColors.primary(context),
                            foregroundColor: Theme.of(context).colorScheme.surface,
                            padding:
                                EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            _showAssignDialog(
                              context,
                              ref,
                              d.id,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.update),
                          label:
                              Text("Update Status"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                AppColors.primary(context),
                            side: BorderSide(
                              color:
                                  AppColors.primary(context),
                            ),
                            padding:
                                EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            _showStatusDialog(
                              context,
                              ref,
                              d.id,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      if (d.customerLat != null &&
                          d.customerLng != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon:
                                Icon(Icons.navigation),
                            label: Text(
                                "Locate Customer"),
                            style:
                                ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  AppColors.leafGreen,
                              foregroundColor:
                                  Theme.of(context).colorScheme.surface,
                              padding:
                                  EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ShopMapModal(
                                  shopLat: d.customerLat!,
                                  shopLng: d.customerLng!,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },

        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary(context),
          ),
        ),

        error: (e, _) => Center(
          child: Text(
            "Error: $e",
            style: TextStyle(
              color: AppColors.error(context),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // PROFESSIONAL INFO TILE
  // =========================
  Widget _infoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // STATUS UPDATE DIALOG
  // =========================
  void _showStatusDialog(
    BuildContext context,
    WidgetRef ref,
    int deliveryId,
  ) {
    String selectedStatus = "picked_up";

    final statuses = [
      "picked_up",
      "in_transit",
      "delivered",
      "failed"
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            "Update Delivery Status",
          ),

          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            items: statuses
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary(context),
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () async {
                final api = ref.read(apiClientProvider);

                await api.post(
                  "deliveries/$deliveryId/update_status/",
                  data: {"status": selectedStatus},
                  fromJson: (json) => json,
                );

                ref.invalidate(
                    sellerDeliveriesProvider);

                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ASSIGN RIDER
  // =========================
  void _showAssignDialog(
    BuildContext context,
    WidgetRef ref,
    int deliveryId,
  ) {
    final idNumber = TextEditingController();
    final fullName = TextEditingController();
    final phone = TextEditingController();
    final altPhone = TextEditingController();

    final vehicleNumber = TextEditingController();
    final vehicleType = TextEditingController();
    final licenseNumber = TextEditingController();

    double? pickupLat;
    double? pickupLng;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text("Assign Rider"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildField(
                  context: context,
                  controller: idNumber,
                  label: "ID Number",
                  icon: Icons.badge_outlined,
                ),

                _buildField(
                  context: context,
                  controller: fullName,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),

                _buildField(
                  context: context,
                  controller: phone,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                ),

                _buildField(
                  context: context,
                  controller: altPhone,
                  label: "Alternative Phone",
                  icon: Icons.phone_callback_outlined,
                ),

                _buildField(
                  context: context,
                  controller: vehicleNumber,
                  label: "Vehicle Number",
                  icon: Icons.directions_car_outlined,
                ),

                _buildField(
                  context: context,
                  controller: vehicleType,
                  label: "Vehicle Type",
                  icon: Icons.local_shipping_outlined,
                ),

                _buildField(
                  context: context,
                  controller: licenseNumber,
                  label: "License Number",
                  icon: Icons.credit_card_outlined,
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.gps_fixed),
                    label: Text(
                        "Generate Pickup GPS"),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          AppColors.leafGreen,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final pos =
                            await Geolocator
                                .getCurrentPosition(
                          desiredAccuracy:
                              LocationAccuracy.high,
                        );

                        setState(() {
                          pickupLat = pos.latitude;
                          pickupLng = pos.longitude;
                        });

                        AppToast.success(context,"Pickup GPS generated successfully");
                      } catch (e) {
                         AppToast.error(context,"GPS Error: ${e.toString()}");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary(context),
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () async {
                final api = ref.read(apiClientProvider);

                await api.post(
                  "deliveries/$deliveryId/assign/",
                  data: {
                    "id_number": idNumber.text,
                    "full_name": fullName.text,
                    "phone_number": phone.text,
                    "alternative_phone":
                        altPhone.text,
                    "vehicle_number":
                        vehicleNumber.text,
                    "vehicle_type":
                        vehicleType.text,
                    "license_number":
                        licenseNumber.text,
                    "pickup_latitude": pickupLat,
                    "pickup_longitude": pickupLng,
                  },
                  fromJson: (json) => json,
                );

                ref.invalidate(
                    sellerDeliveriesProvider);

                Navigator.pop(context);
              },
              child: Text("Assign"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PROFESSIONAL TEXT FIELD
  // =========================
  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Theme.of(context).colorScheme.outline.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.mangoOrange,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}


// ============================
// DELIVERY CODE WIDGET (FIXED)
// ============================
class DeliveryCodeCard extends StatefulWidget {
  final String code;

  const DeliveryCodeCard({super.key, required this.code});

  @override
  State<DeliveryCodeCard> createState() => _DeliveryCodeCardState();
}

class _DeliveryCodeCardState extends State<DeliveryCodeCard> {
  bool isVisible = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DELIVERY CODE",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.copy, size: 18),
                    onPressed: isVisible ? _copy : null,
                  ),
                  IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() => isVisible = !isVisible);
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          GestureDetector(
            onTap: () => setState(() => isVisible = !isVisible),
            child: Text(
              isVisible ? widget.code : "••••••••",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Tap to reveal • Copy & share with rider",
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
