import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/payment_status_model.dart';
import '../../providers/api_provider.dart';
import '../../screens/events/my_tickets_screen.dart';
import '../../screens/hospitality/my_bookings_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/properties/unlocked_properties_screen.dart';
import '../../theme/design_system/app_info_box.dart';
import 'paychangu_visa_webview.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../../widgets/main_app_bar.dart';

class PaymentCheckoutScreen
    extends ConsumerStatefulWidget {
  final int transactionId;
  final double amount;
  final String purpose;
  final String? referenceType;

  final Function(PaymentStatusModel payment)?
      onSuccess;

  const PaymentCheckoutScreen({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.purpose,
    this.referenceType,
    this.onSuccess,
  });

  @override
  ConsumerState<PaymentCheckoutScreen>
      createState() =>
          _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState
    extends ConsumerState<PaymentCheckoutScreen> {
  String selectedMethod = 'airtel_money';

  final _formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final nameController = TextEditingController();

  final cardName = TextEditingController();
  final cardNumber = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();

  Timer? _timer;

  bool loading = false;

  bool get isMobile =>
      selectedMethod == 'airtel_money' ||
      selectedMethod == 'tnm_mpamba';

  bool get isVisa =>
      selectedMethod == 'visa_card';

  final List<Map<String, dynamic>>
      paymentMethods = [
    {
      "value": "airtel_money",
      "name": "Airtel Money",
      "image": "assets/images/airtel.png",
    },
    {
      "value": "tnm_mpamba",
      "name": "TNM Mpamba",
      "image": "assets/images/tnm.png",
    },
    {
      "value": "visa_card",
      "name": "Visa Card",
      "image": "assets/images/visa.png",
    },
  ];

  // ======================
  // PROCESSING DIALOG
  // ======================

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),

              const SizedBox(height: 20),

              Text(
                isMobile
                    ? "Please enter PIN on your phone to complete payment"
                    : "Wait a moment, we are processing your payment",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================
  // INITIATE PAYMENT
  // ======================

  Future<void> initiatePayment() async {
    if (isMobile) {
      if (!_formKey.currentState!
          .validate()) {
        return;
      }
    }

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      final request = <String, dynamic>{
        "amount": widget.amount,
        "purpose": widget.purpose,
        "reference_type":
            widget.referenceType,
        "payment_method": selectedMethod,
      };

      if (widget.referenceType == "order") {
        request["order_id"] =
            widget.transactionId;
      }

      if (widget.referenceType ==
          "booking") {
        request["booking_id"] =
            widget.transactionId;
      }

      if (widget.referenceType ==
          "property_unlock") {
        request["property_unlock_id"] =
            widget.transactionId;
      }

      if (widget.referenceType == "ticket") {
        request["ticket_purchase_id"] =
            widget.transactionId;
      }

      if (isMobile) {
        request.addAll({
          "phone_number":
              phoneController.text,
          "mobile_name":
              nameController.text,
        });
      }

      if (isVisa) {
        request.addAll({
          "card_name": cardName.text,
          "card_number":
              cardNumber.text,
          "expiry": expiry.text,
          "cvv": cvv.text,
        });
      }

      final res = await api.post(
        "payments/initiate_payment/",
        data: request,
        fromJson: (json) => json,
      );

      final paymentReference =
          res['payment_reference'];

      // =====================
// VISA PAYMENT
// =====================

if (isVisa) {

  final visaData = res['visa_payment'];

  // =========================
  // WEB SAFETY CHECK (ADD HERE)
  // =========================
  if (kIsWeb) {
    await launchUrl(
      Uri.parse("http://127.0.0.1:8000/api/payments/payment/visa/?tx_ref=123&amount=200"),
      mode: LaunchMode.externalApplication,
    );
    return;
  }

  // =========================
  // MOBILE → OPEN WEBVIEW
  // =========================
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VisaPaymentWebView(
        paymentData: visaData,
      ),
    ),
  );

  return;
} else {

  // MOBILE MONEY
  final checkoutUrl =
      res['paychangu']
          ?['checkout_url'];

  if (checkoutUrl != null &&
      checkoutUrl.isNotEmpty) {

    await launchUrl(
      Uri.parse(checkoutUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  _startPolling(paymentReference);

  _showProcessingDialog();
}

      _startPolling(paymentReference);

      _showProcessingDialog();
    } catch (e) {
      AppToast.error(
        context,
        "Payment failed: $e",
      );
    }

    setState(() => loading = false);
  }

  // ======================
  // POLLING
  // ======================

  void _startPolling(String reference) {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        try {
          final api =
              ref.read(apiClientProvider);

          final res = await api.get(
            "payments/status/$reference/",
            fromJson: (json) =>
                PaymentStatusModel
                    .fromJson(json),
          );

          if (res.status == "completed") {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            timer.cancel();

            AppToast.success(
              context,
              "Payment successful",
            );

            widget.onSuccess?.call(res);

            if (!mounted) return;

            if (widget.referenceType ==
                "booking") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyBookingsScreen(),
                ),
                (route) => false,
              );
            } else if (widget
                    .referenceType ==
                "order") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const OrdersScreen(),
                ),
                (route) => false,
              );
            } else if (widget
                    .referenceType ==
                "property_unlock") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const UnlockedPropertiesScreen(),
                ),
                (route) => false,
              );
            } else if (widget
                    .referenceType ==
                "ticket") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyTicketsScreen(),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context, res);
            }
          }

          if (res.status == "failed") {
            timer.cancel();

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            AppToast.error(
              context,
              "Payment failed",
            );
          }
        } catch (e) {
          print("Polling error: $e");
        }
      },
    );
  }

  // ======================
  // PAYMENT METHOD CARD
  // ======================

  Widget paymentMethodCard(
    Map<String, dynamic> method,
  ) {
    final isSelected =
        selectedMethod ==
        method['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod =
              method['value'];
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context)
                    .primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.03,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              padding:
                  const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Image.asset(
                method['image'],
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                method['name'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            Icon(
              isSelected
                  ? Icons
                      .radio_button_checked
                  : Icons
                      .radio_button_off,
              color: isSelected
                  ? Theme.of(context)
                      .primaryColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    phoneController.dispose();
    nameController.dispose();

    cardName.dispose();
    cardNumber.dispose();
    expiry.dispose();
    cvv.dispose();

    super.dispose();
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: const MainAppBar(
        title: 'Secure Payment',
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(16),
            children: [
              // ======================
              // HEADER
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
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 38,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "Pay MWK ${widget.amount}",
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      widget.purpose,
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
              // PAYMENT METHODS
              // ======================

              const Text(
                "Select Payment Method",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              ...paymentMethods.map(
                (method) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child:
                      paymentMethodCard(
                    method,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ======================
              // MOBILE MONEY
              // ======================

              if (isMobile) ...[
                AppTextField(
                  label: 'Full Name',
                  hint:
                      'Enter full name',
                  controller:
                      nameController,
                  type:
                      TextFieldType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Full name required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                AppTextField(
                  label:
                      'Phone Number',
                  hint:
                      'e.g 0881234567',
                  controller:
                      phoneController,
                  type:
                      TextFieldType.phone,
                  isRequired: true,
                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Phone number required';
                    }

                    return null;
                  },
                ),
              ],

              // ======================
              // VISA
              // ======================

              if (isVisa)
                AppInfoBox(
                  type: AppInfoType.info,
                  icon: Icons.info_outline,
                  message: "You will be redirected to secure PayChangu checkout.",
              ),

              const SizedBox(height: 30),

              // ======================
              // BUTTON
              // ======================

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : initiatePayment,
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
                  child: loading
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
                          "Pay Now",
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

              const SizedBox(height: 24),

              // ======================
              // POWERED BY
              // ======================

              Center(
                child: Column(
                  children: [
                    Text(
                      "Powered by",
                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Image.asset(
                            'assets/images/changu.png',
                            height: 30,
                          ),

                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}