// lib/screens/delivery/seller_delivery_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';
import '../../widgets/shop_map_modal.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/web_footer.dart';
import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../models/delivery.dart';
import '../../theme/app_colors.dart';
import '../main_tabs_screen.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

// ============================
// PROVIDER
// ============================
final sellerDeliveriesProvider = FutureProvider.autoDispose<List<Delivery>>((ref) async {
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

    return deliveriesAsync.when(
      data: (deliveries) {
        if (deliveries.isEmpty) {
          return _buildEmptyState(context);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deliveries.length,
                      itemBuilder: (context, index) => _DeliveryCard(d: deliveries[index]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Web/Desktop Footer
              const WebFooter(),
            ],
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: AppColors.primary(context),
        ),
      ),
      error: (error, stackTrace) {
        final isNetworkIssue = error is SocketException || 
                             error is HttpException || 
                             error.toString().contains('Network') ||
                             error.toString().contains('Timeout');

        if (isNetworkIssue) {
          return _buildNetworkErrorState(context, ref);
        }

        return _buildGenericErrorState(context, error, ref);
      },
    );
  }

  // =========================
  // EMPTY STATE FALLBACK
  // =========================
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
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
                        Icons.local_shipping_outlined,
                        size: 26,
                        color: AppColors.mangoOrange,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "No Deliveries Found",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      "Active deliveries managed by your profile will appear right here.",
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
          const SizedBox(height: 40),

          // Web/Desktop Footer
          const WebFooter(),
        ],
      ),
    );
  }

  // =========================
  // INTERNET ISSUE FALLBACK
  // =========================
  Widget _buildNetworkErrorState(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
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
                    color: Theme.of(context).colorScheme.error.withOpacity(0.2),
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
                        Icons.wifi_off_rounded,
                        size: 26,
                        color: AppColors.mangoOrange,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Connection Interrupted",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      "Please inspect your internet setup or server route and try again.",
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(sellerDeliveriesProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Retry Connection"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Web/Desktop Footer
          const WebFooter(),
        ],
      ),
    );
  }

  // =========================
  // GENERIC ERROR FALLBACK
  // =========================
  Widget _buildGenericErrorState(BuildContext context, Object error, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
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
                    color: Theme.of(context).colorScheme.error.withOpacity(0.2),
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
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 26,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Something went wrong",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => ref.invalidate(sellerDeliveriesProvider),
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Web/Desktop Footer
          const WebFooter(),
        ],
      ),
    );
  }

  // =========================
  // STATUS UPDATE DIALOG
  // =========================
  void _showStatusDialog(BuildContext context, WidgetRef ref, int deliveryId) {
    String selectedStatus = "in_transit";
    final statuses = ["picked_up", "in_transit",];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Update Delivery Status"),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: statuses
                .map((status) => DropdownMenuItem(value: status, child: Text(status.replaceAll("_", " ").toUpperCase())))
                .toList(),
            onChanged: (value) => setState(() => selectedStatus = value!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () async {
                final api = ref.read(apiClientProvider);
                await api.post(
                  "deliveries/$deliveryId/update_status/",
                  data: {"status": selectedStatus},
                  fromJson: (json) => json,
                );
                ref.invalidate(sellerDeliveriesProvider);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ASSIGN RIDER DIALOG
  // =========================
  void _showAssignDialog(BuildContext context, WidgetRef ref, int deliveryId) {
    final idNumber = TextEditingController();
    final fullName = TextEditingController();
    final phone = TextEditingController();
    final altPhone = TextEditingController();
    final vehicleNumber = TextEditingController();
    final vehicleType = TextEditingController();
    final licenseNumber = TextEditingController();

    double? pickupLat;
    double? pickupLng;
    bool generatingGps = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Assign Rider"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildField(context: context, controller: idNumber, label: "ID Number", icon: Icons.badge_outlined),
                _buildField(context: context, controller: fullName, label: "Full Name", icon: Icons.person_outline),
                _buildField(context: context, controller: phone, label: "Phone Number", icon: Icons.phone_outlined),
                _buildField(context: context, controller: altPhone, label: "Alternative Phone", icon: Icons.phone_callback_outlined),
                _buildField(context: context, controller: vehicleNumber, label: "Vehicle Number", icon: Icons.directions_car_outlined),
                _buildField(context: context, controller: vehicleType, label: "Vehicle Type", icon: Icons.local_shipping_outlined),
                _buildField(context: context, controller: licenseNumber, label: "License Number", icon: Icons.credit_card_outlined),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: generatingGps
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface),
                          )
                        : const Icon(Icons.gps_fixed),
                    label: Text(generatingGps ? "Generating GPS..." : "Generate Pickup GPS"),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.leafGreen,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: generatingGps
                        ? null
                        : () async {
                            setState(() => generatingGps = true);
                            try {
                              final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                              setState(() {
                                pickupLat = pos.latitude;
                                pickupLng = pos.longitude;
                              });
                              AppToast.success(context, "Pickup GPS generated successfully");
                            } catch (e) {
                              AppToast.error(context, "GPS Error: ${e.toString()}");
                            } finally {
                              setState(() => generatingGps = false);
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
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
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
                    "alternative_phone": altPhone.text,
                    "vehicle_number": vehicleNumber.text,
                    "vehicle_type": vehicleType.text,
                    "license_number": licenseNumber.text,
                    "pickup_latitude": pickupLat,
                    "pickup_longitude": pickupLng,
                  },
                  fromJson: (json) => json,
                );
                ref.invalidate(sellerDeliveriesProvider);
                Navigator.pop(context);
              },
              child: const Text("Assign"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Theme.of(context).colorScheme.outline.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.38)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.mangoOrange, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ============================
// COMPONENTIZED DELIVERY CARD (COLLAPSED BY DEFAULT)
// ============================
class _DeliveryCard extends ConsumerStatefulWidget {
  final Delivery d;
  const _DeliveryCard({required this.d});

  @override
  ConsumerState<_DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends ConsumerState<_DeliveryCard> {
  bool isExpanded = false;

  String _formatAttributes(Map<String, dynamic>? attributes) {
    if (attributes == null || attributes.isEmpty) return "";
    return attributes.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= COLLAPSED TOP HEADER (Order Number & Status Only) =================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long, color: AppColors.primary(context)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #${d.orderNumber}",
                            style: TextStyle(
                              fontSize: 17, 
                              fontWeight: FontWeight.bold, 
                              color: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.leafGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              d.status.replaceAll("_", " ").toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.leafGreen, 
                                fontWeight: FontWeight.w600, 
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),

                // ================= EXPANDABLE DETAILS =================
                if (isExpanded) ...[
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: Colors.grey.withOpacity(0.15)),
                  const SizedBox(height: AppSpacing.sm),

                  _infoTile(context: context, icon: Icons.phone, label: "Phone", value: d.phone ?? "-"),
                  const SizedBox(height: 10),
                  _infoTile(context: context, icon: Icons.location_on_outlined, label: "Address", value: d.address ?? "-"),
                  const SizedBox(height: AppSpacing.md),

                  if (d.escrow != null && d.escrow!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Payment Protection (Escrow)", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("Your money is safely held until delivery is completed", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          ...d.escrow!.map((e) => Text("💰 MWK ${e.amount} • ${e.status.toUpperCase()}", style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),

                  if (d.items != null && d.items!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, color: AppColors.primary(context), size: 20),
                              const SizedBox(width: AppSpacing.xs),
                              Text("Items to Deliver", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text(context))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...d.items!.map(
                            (item) {
                              final variantText = _formatAttributes(item['variant_attributes']);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ${item['product_name']} x${item['quantity']}   •   MWK ${item['total_price']}",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (variantText.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 14, top: 2),
                                        child: Text(
                                          "Options: $variantText",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                  if (d.deliveryCode != null) DeliveryCodeCard(code: d.deliveryCode!),

                  const SizedBox(height: AppSpacing.md),

                  // ℹ️ SELLER IN-TRANSIT NOTICE BANNER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.mangoOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.mangoOrange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.mangoOrange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Update status to 'In Transit' to generate customer delivery verification code.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: const Text("Assign Rider"),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary(context),
                            foregroundColor: Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => const SellerDeliveryScreen()._showAssignDialog(context, ref, d.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.update, size: 18),
                          label: const Text("Status"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary(context),
                            side: BorderSide(color: AppColors.primary(context)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => const SellerDeliveryScreen()._showStatusDialog(context, ref, d.id),
                        ),
                      ),
                    ],
                  ),
                  if (d.customerLat != null && d.customerLng != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text("Locate Customer"),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.leafGreen,
                          foregroundColor: Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          MainTabsScreen.of(context)?.navigateToShopMap(
                            d.customerLat!,
                            d.customerLng!,
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: AppColors.text(context)),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================
// DELIVERY CODE WIDGET
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: isVisible ? _copy : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => setState(() => isVisible = !isVisible),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => isVisible = !isVisible),
            child: Text(
              isVisible ? widget.code : "••••••••",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3),
            ),
          ),
          const SizedBox(height: 4),
          Text("Tap to reveal • Copy & share with rider", style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}