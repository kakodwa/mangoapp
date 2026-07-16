// lib/screens/checkout/checkout_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/web_footer.dart';
import '../../providers/api_provider.dart';
import '../../providers/products_provider.dart';
import '../orders/orders_screen.dart';
import '../main_tabs_screen.dart'; 
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../payments/payment_checkout_screen.dart';
import '../../theme/design_system/app_spacing.dart';

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
    return attributes.entries.map((e) => "${e.key}: ${e.value}").join(", ");
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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    // ✅ Scaffold, AppBar, and SafeArea completely removed to support nested tab layout
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ======================
          // ORDER SUMMARY HEADER
          // ======================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Theme.of(context).colorScheme.surface,
                  size: 38,
                ),
                const SizedBox(height: 10),
                Text(
                  "Order Checkout",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Complete your order payment securely",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ======================
          // ORDER ITEMS
          // ======================
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

          const SizedBox(height: AppSpacing.lg),

          // ======================
          // DELIVERY DETAILS
          // ======================
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

          // ======================
          // GPS BUTTON
          // ======================
          SizedBox(
            height: 54,
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
                            color: Theme.of(context).primaryColor,
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

          const SizedBox(height: AppSpacing.lg),

          // ======================
          // PRICING SUMMARY TOTAL
          // ======================
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
              children: [
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ======================
          // BUTTON PLACE ORDER
          // ======================
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
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

          // ✅ Added WebFooter inside the list viewport to follow content naturally
          const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: WebFooter(),
          ),
        ],
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

      // Look up the tabs manager system context
      final tabsScreen = MainTabsScreen.of(context);

      if (tabsScreen != null) {
        // ✅ FIXED: Routes directly inside the tab slot view framework engine at index 42
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
        // Standard context route stack fallback execution
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