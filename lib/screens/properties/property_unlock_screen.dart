<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

=======
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/properties_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
<<<<<<< HEAD
import '../../utils/app_toast.dart';

import '../payments/payment_checkout_screen.dart';
import 'property_details_screen.dart';

=======
import 'property_details_screen.dart';

import '../../utils/app_toast.dart';
import '../../utils/api_response_handler.dart';

>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
class PropertyUnlockScreen extends ConsumerStatefulWidget {
  final int propertyId;
  final String propertyTitle;
  final double unlockFee;

  const PropertyUnlockScreen({
<<<<<<< HEAD
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.unlockFee,
  });
=======
    Key? key,
    required this.propertyId,
    required this.propertyTitle,
    required this.unlockFee,
  }) : super(key: key);
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

  @override
  ConsumerState<PropertyUnlockScreen> createState() =>
      _PropertyUnlockScreenState();
}

class _PropertyUnlockScreenState
    extends ConsumerState<PropertyUnlockScreen> {
<<<<<<< HEAD
  bool _isProcessing = false;

  /// default method (backend will still receive from payment screen)
  final String _selectedPaymentMethod = 'airtel_money';

  /// ================= CREATE UNLOCK THEN GO TO PAYMENT =================
  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final api = ref.read(apiClientProvider);

      /// 1️⃣ CREATE PROPERTY UNLOCK
      final unlockResponse = await api.post(
        'properties/${widget.propertyId}/unlock/',
        data: {
          'payment_method': _selectedPaymentMethod,
        },
        fromJson: (json) => json,
      );

      final unlockId = unlockResponse['property_unlock_id'];

      if (unlockId == null) {
        throw Exception("Unlock ID not returned from server");
      }

      if (!mounted) return;

      /// 2️⃣ NAVIGATE TO PAYMENT SCREEN (NO PAYMENT HERE)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentCheckoutScreen(
            transactionId: unlockId,

            amount: widget.unlockFee,
            purpose: "property_unlock",
            referenceType: "property_unlock",

            onSuccess: (_) {
              AppToast.success(
                context,
                'Property unlocked successfully',
              );

              ref.invalidate(
                propertyDetailsProvider(widget.propertyId),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsScreen(
                    propertyId: widget.propertyId,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ),
      );
    } catch (e) {
      AppToast.error(context, 'Failed: ${e.toString()}');
    }

    setState(() => _isProcessing = false);
  }

=======

  String _selectedPaymentMethod = 'airtel_money';
  bool _isProcessing = false;

  /// Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  Timer? _paymentTimer;

  bool get _isMobileMoney =>
      _selectedPaymentMethod == 'airtel_money' ||
      _selectedPaymentMethod == 'tnm_mpamba';

  bool get _isVisa =>
      _selectedPaymentMethod == 'visa_card';

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



  Future<void> _startPaymentVerification(
  String paymentReference,
) async {

  _paymentTimer?.cancel();

  _paymentTimer = Timer.periodic(
    const Duration(seconds: 5),
    (timer) async {

      try {

        final api = ref.read(apiClientProvider);

        final response = await api.get(
          'payments/check_payment_status/?reference=$paymentReference',
          fromJson: (json) => json,
        );

        final status = response['status'];

        print("PAYMENT STATUS => $status");

        /// PAYMENT SUCCESS
        if (status == "completed") {

          timer.cancel();

          if (!mounted) return;

          /// refresh property details
          ref.invalidate(
            propertyDetailsProvider(widget.propertyId),
          );

          /// success toast

          AppToast.success(context, 'Property unlocked successfully');

          /// redirect to property details
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailsScreen(
                propertyId: widget.propertyId,
              ),
            ),
            (route) => false,
          );
        }

        /// PAYMENT FAILED
        else if (status == "failed") {

          timer.cancel();
          AppToast.error(context,'Payment failed');
        }

      } catch (e) {

        print("VERIFY ERROR: $e");
      }
    },
  );
}


Future<void> _processPayment() async {
  setState(() => _isProcessing = true);

  try {
    final api = ref.read(apiClientProvider);

    /// ============================
    /// 1️⃣ CREATE PROPERTY UNLOCK FIRST
    /// ============================
    final unlockResponse = await api.post(
      'properties/${widget.propertyId}/unlock/',
      data: {
        'payment_method': _selectedPaymentMethod,
      },
      fromJson: (json) => json,
    );

    final unlockId = unlockResponse['property_unlock_id'];

    if (unlockId == null) {
      throw Exception("Unlock ID not returned from server");
    }

    /// ============================
    /// 2️⃣ INITIATE PAYMENT USING unlock_id (NOT order_id)
    /// ============================
    final paymentResponse = await api.post(
      'payments/initiate_payment/',
      data: {
        'property_unlock_id': unlockId,
        'payment_method': _selectedPaymentMethod,

        /// MOBILE MONEY
        if (_isMobileMoney) ...{
          'full_name': _fullNameController.text,
          'phone_number': _phoneController.text,
        },

        /// VISA
        if (_isVisa) ...{
          'card_name': _cardNameController.text,
          'card_number': _cardNumberController.text,
          'expiry': _expiryController.text,
          'cvv': _cvvController.text,
        },
      },
      fromJson: (json) => json,
    );

 /// ============================
/// 3️⃣ HANDLE RESPONSE
/// ============================

final paymentReference =
    paymentResponse['payment_reference'];

final paymentUrl =
    paymentResponse['paychangu']?['checkout_url'];

/// open card payment url
if (paymentUrl != null &&
    paymentUrl.toString().isNotEmpty) {

  await launchUrl(
    Uri.parse(paymentUrl),
    mode: LaunchMode.externalApplication,
  );
}

/// start checking payment automatically
if (paymentReference != null) {

  AppToast.info(context,"Waiting for payment confirmation...");

  _startPaymentVerification(
    paymentReference,
  );
}

  } catch (e) {;
    AppToast.error(context, 'Payment failed: ${e.toString()}');
  }

  setState(() => _isProcessing = false);
}

>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Unlock Property'),
<<<<<<< HEAD
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// PROPERTY CARD (UNCHANGED)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mangoOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mangoOrange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock, color: AppColors.mangoOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.propertyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('What you\'ll get after unlocking:'),
                const SizedBox(height: 8),
                _buildFeature('Full property description and details'),
                _buildFeature('Exact location on map'),
                _buildFeature('Contact information of property owner'),
                _buildFeature('Property inspection history'),
              ],
            ),
          ),

          /// AMOUNT CARD (UNCHANGED)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.darkText.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Unlock Fee:'),
                  Text(
                    'MWK ${widget.unlockFee.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.mangoOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mangoOrange,
                ),
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.lock_open),
                label: Text(
                  _isProcessing
                      ? 'Preparing payment...'
                      : 'Pay & Unlock (MWK ${widget.unlockFee.toStringAsFixed(2)})',
                ),
              ),
            ),
=======
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PROPERTY CARD
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mangoOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mangoOrange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock,
                          color: AppColors.mangoOrange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Locked Property',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        AppColors.mangoOrange,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            Text(
                              widget.propertyTitle,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                      'What you\'ll get after unlocking:'),
                  const SizedBox(height: 8),
                  _buildFeature(
                      'Full property description and details'),
                  _buildFeature('Exact location on map'),
                  _buildFeature(
                      'Contact information of property owner'),
                  _buildFeature(
                      'Property inspection history'),
                ],
              ),
            ),

            /// AMOUNT
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.darkText
                          .withOpacity(0.2)),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Unlock Fee:'),
                    Text(
                      'MWK ${widget.unlockFee.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                              AppColors.mangoOrange,
                          fontWeight:
                              FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// PAYMENT METHODS
            ..._paymentMethods.map((method) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(
                        horizontal: 16),
                child: Card(
                  child: RadioListTile<String>(
                    value: method['id'],
                    groupValue:
                        _selectedPaymentMethod,
                    activeColor:
                        AppColors.mangoOrange,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod =
                            value!;
                      });
                    },
                    title: Text(method['name']),
                    secondary: SizedBox(
                      width: 42,
                      height: 42,
                      child: Image.asset(
                        method['logo'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            }),

            if (_isMobileMoney) _buildMobileMoneyForm(),
            if (_isVisa) _buildVisaForm(),

            const SizedBox(height: 24),

            /// PAY BUTTON
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.mangoOrange,
                  ),
                  onPressed:
                      _isProcessing
                          ? null
                          : _processPayment,
                  icon: _isProcessing
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Icon(
                          Icons.lock_open),
                  label: Text(
                    _isProcessing
                        ? 'Processing...'
                        : 'Pay & Unlock (MWK ${widget.unlockFee.toStringAsFixed(2)})',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMoneyForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _cardNameController,
            decoration: const InputDecoration(
              labelText: 'Card Holder Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Expiry',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  decoration:
                      const InputDecoration(
                    labelText: 'CVV',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),
            ],
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String feature) {
    return Row(
      children: [
<<<<<<< HEAD
        Icon(Icons.check_circle, color: AppColors.mangoOrange),
=======
        Icon(Icons.check_circle,
            color: AppColors.mangoOrange),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
        const SizedBox(width: 8),
        Expanded(child: Text(feature)),
      ],
    );
  }
<<<<<<< HEAD
=======

  @override
  void dispose() {

  _paymentTimer?.cancel();

  super.dispose();
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
}