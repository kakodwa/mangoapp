import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        widget.delivery.status = status;
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
      backgroundColor: Theme.of(context).colorScheme.outline.shade100,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary(context),
        title: Text(
          "Order #${d.orderNumber}",
          style: const TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= STATUS CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
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
                        const Text(
                          "Delivery Status",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxs),

                        Text(
                          d.status.toString().toUpperCase(),
                          style: const TextStyle(
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
              padding: const EdgeInsets.all(18),
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
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.shade200,
                ),
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary.shade700,
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Expanded(
                    child: Text(
                      "Please once you deliver the order, let the owner of this business update the delivery status.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.shade900,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= ITEMS =================
            if (d.items != null && d.items!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        padding:
                            const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.shade50,
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
                                      Theme.of(context).colorScheme.outline.shade800,
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

            // ================= MAP BUTTON =================
            if (d.customerLat != null &&
                d.customerLng != null)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation),
                  label: const Text(
                    "Navigate to Customer",
                  ),

                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        AppColors.leafGreen,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding:
                        const EdgeInsets.symmetric(
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
          color: Theme.of(context).colorScheme.outline.shade600,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline.shade700,
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