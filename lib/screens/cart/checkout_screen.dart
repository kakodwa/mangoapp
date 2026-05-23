import 'dart:async';
<<<<<<< HEAD

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/api_provider.dart';
import '../../providers/products_provider.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../../widgets/main_app_bar.dart';
import '../orders/orders_screen.dart';
import '../payments/payment_checkout_screen.dart';
=======
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/main_app_bar.dart';


import '../../theme/app_colors.dart';
import '../orders/orders_screen.dart';

import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem> items;
  final double total;

  const CheckoutScreen({
    Key? key,
    required this.items,
    required this.total,
  }) : super(key: key);

  @override
<<<<<<< HEAD
  ConsumerState<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _deliveryAddressController =
      TextEditingController();

  final _deliveryPhoneController =
      TextEditingController();

  bool _isProcessing = false;

  double? _latitude;
  double? _longitude;

  bool _gettingLocation = false;

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _deliveryPhoneController.dispose();

    super.dispose();
  }

  // ================= GPS =================

=======
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _deliveryAddressController = TextEditingController();
  final _deliveryPhoneController = TextEditingController();

  final _paymentPhoneController = TextEditingController();
  final _mobileNameController = TextEditingController();

  /// VISA
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  
  

  Timer? _paymentTimer;

  String _selectedPaymentMethod = 'airtel_money';
  bool _isProcessing = false;

  /// GPS
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'airtel_money',
      'name': 'Airtel Money',
      'logo': 'assets/images/airtel.png',
      'description': 'Fast and secure mobile money',
    },
    {
      'id': 'tnm_mpamba',
      'name': 'TNM Mpamba',
      'logo': 'assets/images/tnm.png',
      'description': 'TNM mobile money wallet',
    },
    {
      'id': 'visa_card',
      'name': 'Visa Card',
      'logo': 'assets/images/visa.png',
      'description': 'Pay securely with Visa card',
    },
  ];

  bool get _isMobileMoney =>
      _selectedPaymentMethod == 'airtel_money' ||
      _selectedPaymentMethod == 'tnm_mpamba';

  bool get _isVisa => _selectedPaymentMethod == 'visa_card';

  @override
void dispose() {

  _paymentTimer?.cancel();

  _deliveryAddressController.dispose();
  _deliveryPhoneController.dispose();
  _paymentPhoneController.dispose();
  _cardNameController.dispose();
  _cardNumberController.dispose();
  _expiryController.dispose();
  _cvvController.dispose();

  super.dispose();
}



  Future<void> _startPaymentVerification(
  String paymentReference,
) async {

  _paymentTimer?.cancel();

  _paymentTimer = Timer.periodic(
    const Duration(seconds: 5),
    (timer) async {

      try {

        final api = ref.read(apiClientProvider);

        final response = await api.checkPaymentStatus(
          paymentReference,
        );

        final status = response['status'];

        print("ORDER PAYMENT STATUS => $status");

        /// PAYMENT SUCCESS
        if (status == "completed") {

          timer.cancel();

          if (!mounted) return;

          /// refresh orders
          ref.invalidate(userOrdersProvider);

          /// success toast
          AppToast.success(context,"Order payment successful");

          /// redirect to orders
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const OrdersScreen(),
            ),
            (route) => false,
          );
        }

        /// PAYMENT FAILED
        else if (status == "failed") {

          timer.cancel();

          AppToast.error(context,"Payment failed");
        }

      } catch (e) {

        print("VERIFY ERROR => $e");
      }
    },
  );
}

  /// ===================== GPS =====================
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);

    try {
<<<<<<< HEAD
      bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        AppToast.info(
          context,
          "Enable GPS first",
        );

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      Position pos =
          await Geolocator
              .getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
=======
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppToast.info(context,"Enable GPS first");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      );

      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
<<<<<<< HEAD

      AppToast.success(
        context,
        "Location captured",
      );
    } finally {
      setState(
        () => _gettingLocation = false,
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: const MainAppBar(
        title: 'Checkout',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(16),
            children: [
              // ======================
              // ORDER SUMMARY
              // ======================

              Container(
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context)
                          .primaryColor,
                      Theme.of(context)
                          .primaryColor
                          .withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 38,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Order Checkout",
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      "Complete your order payment securely",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors
                            .white
                            .withOpacity(
                          0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======================
              // ORDER ITEMS
              // ======================

              const Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.03,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children:
                      widget.items.map(
                    (item) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item.product.name} x${item.quantity}",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Text(
                              "MWK ${item.totalPrice.toStringAsFixed(2)}",
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // ======================
              // DELIVERY DETAILS
              // ======================

              const Text(
                "Delivery Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              AppTextField(
                label:
                    'Delivery Address',
                hint:
                    'Enter delivery address',
                controller:
                    _deliveryAddressController,
                type:
                    TextFieldType.multiline,
                maxLines: 3,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Delivery address required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                label:
                    'Delivery Phone Number',
                hint: 'e.g 0881234567',
                controller:
                    _deliveryPhoneController,
                type:
                    TextFieldType.phone,
                isRequired: true,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
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
                child: OutlinedButton.icon(
                  onPressed:
                      _gettingLocation
                          ? null
                          : _getLocation,
                  style:
                      OutlinedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.gps_fixed,
                  ),
                  label: Text(
                    _gettingLocation
                        ? "Getting location..."
                        : "Get My Location",
                  ),
                ),
              ),

              if (_latitude != null) ...[
                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border: Border.all(
                      color: Colors
                          .green
                          .shade100,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons
                                .check_circle,
                            color:
                                Colors.green,
                            size: 18,
                          ),

                          SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              "GPS location captured successfully",
                              style:
                                  TextStyle(
                                fontSize:
                                    13,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "Lat: $_latitude\nLng: $_longitude",
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey,
=======
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  /// ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ORDER SUMMARY
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: widget.items.map((item) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.product.name)),
                      Text('MWK ${item.totalPrice}'),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            /// DELIVERY INFO
            TextField(
              controller: _deliveryAddressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

  
            TextField(
              controller: _deliveryPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Delivery Phone Number',
                border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 16),

            /// ================= GPS (NOW ONLY ONCE HERE) =================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _getLocation,
                icon: const Icon(Icons.gps_fixed),
                label: Text(
                  _gettingLocation ? "Getting location..." : "Get My Location",
                ),
              ),
            ),

            if (_latitude != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "This GPS will be used during delivery so record exactly where they can find you",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Lat: $_latitude, Lng: $_longitude",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  ),
            const SizedBox(height: 24),

            /// PAYMENT METHODS
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            ..._paymentMethods.map((method) {
              final selected = _selectedPaymentMethod == method['id'];

              return Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: method['id'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      title: Text(method['name']),
                      subtitle: Text(method['description']),
                      secondary: Image.asset(
                        method['logo'],
                        width: 40,
                      ),
                    ),

                    if (selected)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [

                            if (_isMobileMoney) ...[
                              TextField(
                                controller: _mobileNameController,
                                decoration: const InputDecoration(
                                  labelText: "Full Name",
                                  border: OutlineInputBorder(),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _paymentPhoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Money Number',
                                  border: OutlineInputBorder(),
                                  ),
                                ),
                            ],

                            if (_isVisa) ...[
                              TextField(
                                controller: _cardNameController,
                                decoration: const InputDecoration(
                                  labelText: "Card Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _cardNumberController,
                                decoration: const InputDecoration(
                                  labelText: "Card Number",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _expiryController,
                                      decoration: const InputDecoration(
                                        labelText: "Expiry",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _cvvController,
                                      decoration: const InputDecoration(
                                        labelText: "CVV",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

             const SizedBox(height: 20),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
            
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock,
                          size: 16,
                          color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Secure payments powered by',
                        style: TextStyle(
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/changu.png',
                    height: 30,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ORDER TOTAL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('MWK ${widget.total.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'MWK ${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                ),
              ],

              const SizedBox(height: 24),

              // ======================
              // TOTAL
              // ======================

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.03,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          "Subtotal",
                        ),

                        Text(
                          "MWK ${widget.total.toStringAsFixed(2)}",
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: const [
                        Text(
                          "Shipping",
                        ),

                        Text(
                          "MWK 0.00",
                        ),
                      ],
                    ),

                    const Divider(
                      height: 24,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        Text(
                          "MWK ${widget.total.toStringAsFixed(2)}",
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ======================
              // BUTTON
              // ======================

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isProcessing
                          ? null
                          : _placeOrder,
                  style:
                      ElevatedButton
                          .styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors
                                    .white,
                            strokeWidth:
                                2.5,
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style:
                              TextStyle(
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
=======
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _placeOrder,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Place Order'),
              ),
            ),
          ],
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        ),
      ),
    );
  }

<<<<<<< HEAD
  // ================= PLACE ORDER =================

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(
      () => _isProcessing = true,
    );

    try {
      final apiClient =
          ref.read(apiClientProvider);

      final orderResponse =
          await apiClient.post(
        'orders/',
        data: {
          'delivery_address':
              _deliveryAddressController
                  .text,

          'delivery_phone':
              _deliveryPhoneController
                  .text,

          'lat': _latitude,
          'lng': _longitude,

          'items': widget.items
              .map(
                (item) => {
                  'product_id':
                      item.product.id,
                  'quantity':
                      item.quantity,
                },
              )
              .toList(),

          'total_amount':
              widget.total,
        },
        fromJson: (json) => json,
      );

      final orderId =
          orderResponse['id'];

      if (!mounted) return;

      AppToast.success(
        context,
        "Order created successfully",
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentCheckoutScreen(
            transactionId: orderId,
            amount: widget.total,
            purpose:
                "order_payment",
            referenceType:
                "order",
            onSuccess: (payment) {
              ref.invalidate(
                userOrdersProvider,
              );

              ref
                  .read(
                    cartProvider
                        .notifier,
                  )
                  .state = [];
            },
          ),
        ),
      );
    } catch (e) {
      AppToast.error(
        context,
        "Failed: $e",
      );
    } finally {
      setState(
        () => _isProcessing = false,
      );
    }
  }
=======
  Future<void> _placeOrder() async {
  setState(() => _isProcessing = true);

  try {
    final apiClient = ref.read(apiClientProvider);

    /// ===============================
    /// 1️⃣ CREATE ORDER (NO PAYMENT DATA HERE)
    /// ===============================
    final orderResponse = await apiClient.post(
      'orders/',
      data: {
        'payment_method': _selectedPaymentMethod,

        // DELIVERY INFO
        'delivery_address': _deliveryAddressController.text,
        'delivery_phone': _deliveryPhoneController.text,

        // GPS
        'lat': _latitude,
        'lng': _longitude,

        // ITEMS
        'items': widget.items.map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            }).toList(),

        'total_amount': widget.total,
      },
      fromJson: (json) => json,
    );

    final orderId = orderResponse['id'];

    /// ===============================
    /// 2️⃣ INITIATE PAYMENT (ALL PAYMENT DATA HERE)
    /// ===============================
    final paymentResponse = await apiClient.post(
      'payments/initiate_payment/',
      data: {
        'order_id': orderId,
        'amount': widget.total,
        'payment_method': _selectedPaymentMethod,

        /// 📱 MOBILE MONEY DETAILS
        if (_isMobileMoney) ...{
          'mobile_name': _mobileNameController.text,
          'phone_number': _paymentPhoneController.text,

        },

        /// 💳 VISA CARD DETAILS
        if (_isVisa) ...{
          'card_name': _cardNameController.text,
          'card_number': _cardNumberController.text,
          'expiry': _expiryController.text,
          'cvv': _cvvController.text,
        },
      },
      fromJson: (json) => json,
    );


    if (paymentResponse['success'] == false) {
      AppToast.error(context,paymentResponse['message'] ?? "Payment failed");
      setState(() => _isProcessing = false);
      return;
    }


/// 3️⃣ HANDLE PAYMENT RESPONSE
/// ===============================

final paymentReference =
    paymentResponse['payment_reference'];

final paymentUrl =
    paymentResponse['paychangu']?['checkout_url'];

/// OPEN VISA/CARD PAYMENT PAGE
if (paymentUrl != null &&
    paymentUrl.toString().isNotEmpty) {

  await launchUrl(
    Uri.parse(paymentUrl),
    mode: LaunchMode.externalApplication,
  );
}

/// START PAYMENT VERIFICATION
if (paymentReference != null) {

  AppToast.info(context,"Waiting for payment confirmation...");

  _startPaymentVerification(
    paymentReference,
  );
}

/// CLEAR CART
ref.read(cartProvider.notifier).state = [];

  } catch (e) {
    print("ORDER ERROR: $e");
    AppToast.error(context,"Failed: $e");
  } finally {
    setState(() => _isProcessing = false);
  }
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
}