// lib/screens/checkout/checkout_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/api_provider.dart';
import '../../providers/products_provider.dart';
import '../orders/orders_screen.dart';
import '../main_tabs_screen.dart'; 
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../payments/payment_checkout_screen.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../widgets/web_footer.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem> items;
  final double total;

  const CheckoutScreen({
    Key? key,
    required this.items,
    required this.total,
  }) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _deliveryAddressController = TextEditingController();
  final _deliveryPhoneController = TextEditingController();

  bool _isProcessing = false;
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;

  String _formatAttributes(Map<String, dynamic>? attributes) {
    if (attributes == null || attributes.isEmpty) return "";

    final validEntries = attributes.entries.where((e) {
      final key = e.key.toString().trim().toUpperCase();
      final val = e.value?.toString().trim().toUpperCase() ?? '';

      if (val.isEmpty || val == "N/A" || val == "NONE" || val == "NULL") {
        return false;
      }
      if (key == "N/A" || key.isEmpty) {
        return false;
      }
      return true;
    }).map((e) => "${e.key}: ${e.value}").toList();

    return validEntries.join(", ");
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _deliveryPhoneController.dispose();
    super.dispose();
  }

  // ================= GPS =================

  Future<void> _getLocation() async {
    if (!mounted) return;

    setState(() => _gettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        AppToast.info(context, "Enable GPS first");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          AppToast.error(context, "Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppToast.error(context, "Location permission permanently denied");
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });

      AppToast.success(context, "Location captured successfully");
    } catch (e) {
      AppToast.error(context, "GPS Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _gettingLocation = false);
      }
    }
  }

  // ================= HELPER BUILDERS =================

  /// Wide rounded card header spanning full width of the container
  Widget _buildOrderHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.mangoOrange,
            AppColors.mangoOrange.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mangoOrange.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 44,
          ),
          SizedBox(height: 10),
          Text(
            "Order Checkout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Complete your order payment securely",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Order Summary",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: widget.items.map((item) {
              final variantText = _formatAttributes(item.variant?.attributes);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.product.name} x${item.quantity}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (variantText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              variantText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "MWK ${item.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Delivery Address',
          hint: 'Enter delivery address',
          controller: _deliveryAddressController,
          type: TextFieldType.multiline,
          maxLines: 3,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Delivery address required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Delivery Phone Number',
          hint: 'e.g 0881234567',
          controller: _deliveryPhoneController,
          type: TextFieldType.phone,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number required';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 54,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _gettingLocation ? null : _getLocation,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _gettingLocation
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.mangoOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Getting location...",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.gps_fixed),
                      SizedBox(width: 8),
                      Text(
                        "Get My Location",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
        if (_latitude != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "GPS location captured successfully",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Lat: $_latitude\nLng: $_longitude",
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPricingAndActionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Payment Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal"),
              Text("MWK ${widget.total.toStringAsFixed(2)}"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Shipping"),
              Text("MWK 0.00"),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                "MWK ${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mangoOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI BUILD =================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    // Wide rounded card spanning the full width
                    _buildOrderHeaderCard(),

                    const SizedBox(height: AppSpacing.lg),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN: Items Summary & Delivery Form
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildOrderSummaryItems(),
                                const SizedBox(height: AppSpacing.lg),
                                _buildDeliveryForm(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // RIGHT COLUMN: Payment Summary & Place Order Button
                          Expanded(
                            flex: 5,
                            child: _buildPricingAndActionCard(),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderSummaryItems(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildDeliveryForm(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildPricingAndActionCard(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Web/Desktop Footer
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final apiClient = ref.read(apiClientProvider);

      final orderResponse = await apiClient.post(
        'orders/',
        data: {
          'delivery_address': _deliveryAddressController.text,
          'delivery_phone': _deliveryPhoneController.text,
          'lat': _latitude,
          'lng': _longitude,
          'items': widget.items
              .map(
                (item) => {
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                  'variant_attributes': item.variant?.attributes,
                },
              )
              .toList(),
          'total_amount': widget.total,
        },
        fromJson: (json) => json,
      );

      final orderId = orderResponse['id'];
      if (!mounted) return;

      AppToast.success(context, "Order created successfully");

      final tabsScreen = MainTabsScreen.of(context);

      if (tabsScreen != null) {
        tabsScreen.navigateToPayment(
          transactionId: orderId,
          amount: widget.total,
          purpose: "order_payment",
          referenceType: "order",
          onSuccess: (payment) {
            ref.invalidate(ordersPaginationProvider);
            ref.read(cartProvider.notifier).state = [];
          },
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentCheckoutScreen(
              transactionId: orderId,
              amount: widget.total,
              purpose: "order_payment",
              referenceType: "order",
              onSuccess: (payment) {
                ref.invalidate(ordersPaginationProvider);
                ref.read(cartProvider.notifier).state = [];
              },
            ),
          ),
        );
      }
    } catch (e) {
      AppToast.error(context, "Failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}