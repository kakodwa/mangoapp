import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/shop_map_modal.dart';
import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';

class RiderDeliveryScreen extends ConsumerStatefulWidget {
  final dynamic delivery;

  const RiderDeliveryScreen({
    super.key,
    required this.delivery,
  });

  @override
  ConsumerState<RiderDeliveryScreen> createState() =>
      _RiderDeliveryScreenState();
}

class _RiderDeliveryScreenState
    extends ConsumerState<RiderDeliveryScreen> {
  bool loading = false;

  final TextEditingController verifyCodeController =TextEditingController();
  String currentStatus = "";

  @override
  void initState() {
    super.initState();
    currentStatus = widget.delivery.status;
  }


  Future<void> _verifyDelivery() async {
  if (verifyCodeController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Enter customer verification code"),
      ),
    );
    return;
  }

  setState(() => loading = true);

  try {
    final api = ref.read(apiClientProvider);

    await api.post(
      "deliveries/${widget.delivery.id}/verify_delivery/",
      data: {
        "code": verifyCodeController.text.trim(),
      },
      fromJson: (json) => json,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Delivery completed successfully"),
      ),
    );

    setState(() {
      currentStatus = "delivered";
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }

  setState(() => loading = false);
}

  Future<void> _updateStatus(String status) async {
    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      await api.post(
        "deliveries/${widget.delivery.id}/update_status/",
        data: {"status": status},
        fromJson: (json) => json,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated: $status"),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      setState(() {
        currentStatus = status;

      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.delivery;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary(context),
        title: Text(
          "Order #${d.orderNumber}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= STATUS CARD =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary(context),
                    AppColors.mangoLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: Theme.of(context).colorScheme.surface,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delivery Status",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxs),

                        Text(
                          currentStatus.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= CUSTOMER INFO =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
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

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color:
                            AppColors.primary(context),
                      ),

                      const SizedBox(width: AppSpacing.xs),

                      Text(
                        "Customer Information",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              AppColors.text(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _infoTile(
                    icon: Icons.phone,
                    label: "Phone",
                    value: d.phone ?? "-",
                  ),

                  const SizedBox(height: 14),

                  _infoTile(
                    icon: Icons.location_on_outlined,
                    label: "Address",
                    value: d.address ?? "-",
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= INFO MESSAGE =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                ),
              ),

              child: Container(
  width: double.infinity,
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.05),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.green.withOpacity(0.2),
    ),
  ),
  child: const Text(
    "Update delivery progress below. Once the order reaches the customer, ask for the verification code to complete delivery.",
    style: TextStyle(height: 1.5),
  ),
),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= ITEMS =================
            if (d.items != null && d.items!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                        ),

                        const SizedBox(width: AppSpacing.xs),

                        Text(
                          "Items to Deliver",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                            color:
                                AppColors.text(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    ...d.items!.map(
                      (item) => Container(
                        margin:
                            EdgeInsets.only(
                          bottom: 10,
                        ),
                        padding:
                            EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration:
                                  BoxDecoration(
                                color:
                                    AppColors.primary(
                                        context),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.sm),

                            Expanded(
                              child: Text(
                                "${item['product_name']} x${item['quantity']}",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.outline.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: AppSpacing.lg),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Delivery Actions",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 16),

      if (currentStatus == "assigned")
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.inventory),
            label: const Text("Mark as Picked Up"),
            onPressed: loading
                ? null
                : () => _updateStatus("picked_up"),
          ),
        ),

      if (currentStatus == "picked_up")
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping),
            label: const Text("Mark as In Transit"),
            onPressed: loading
                ? null
                : () => _updateStatus("in_transit"),
          ),
        ),

      if (currentStatus == "delivered")
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Delivery completed successfully",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  ),
),


const SizedBox(height: AppSpacing.lg),

if (currentStatus == "in_transit") ...[
  const SizedBox(height: AppSpacing.md),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.orange.withOpacity(0.2),
      ),
    ),
    child: Column(
      children: [

        const Icon(
          Icons.verified_user,
          size: 40,
          color: Colors.orange,
        ),

        const SizedBox(height: 10),

        const Text(
          "Customer Verification",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Ask the customer for the delivery code before completing delivery.",
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        TextField(
          controller: verifyCodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Customer Code",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text("Complete Delivery"),
            onPressed: loading
                ? null
                : _verifyDelivery,
          ),
        ),
      ],
    ),
  ),
],

            const SizedBox(height: AppSpacing.lg),

            if (d.phone != null && d.phone.toString().isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.phone),
        label: const Text("Call Customer"),
        onPressed: () async {
          await launchUrl(
            Uri.parse("tel:${d.phone}"),
          );
        },
      ),
    ),
  ),

  const SizedBox(height: AppSpacing.lg),

            // ================= MAP BUTTON =================
            if (d.customerLat != null &&
                d.customerLng != null)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: Icon(Icons.navigation),
                  label: Text(
                    "Navigate to Customer",
                  ),

                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        AppColors.leafGreen,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
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
  }

  // ================= INFO TILE =================
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: RichText(
            text: TextSpan(
              style:
                  const TextStyle(fontSize: 14),
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
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}