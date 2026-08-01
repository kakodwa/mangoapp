// lib/screens/payments/payment_checkout_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/payment_status_model.dart';
import '../../providers/api_provider.dart';
import '../../screens/main_tabs_screen.dart'; 
import '../../theme/design_system/app_info_box.dart';
import 'paychangu_visa_webview.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../widgets/web_footer.dart';
import '../../utils/price_helper.dart';
import '../orders/orders_screen.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  final int transactionId;
  final double amount;
  final String purpose;
  final String? referenceType;

  final Function(PaymentStatusModel payment)? onSuccess;

  const PaymentCheckoutScreen({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.purpose,
    this.referenceType,
    this.onSuccess,
  });

  @override
  ConsumerState<PaymentCheckoutScreen> createState() =>
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

  final List<Map<String, dynamic>> paymentMethods = [
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

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    cardName.dispose();
    cardNumber.dispose();
    expiry.dispose();
    cvv.dispose();
    _timer?.cancel();
    super.dispose();
  }

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
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
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
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      final request = <String, dynamic>{
        "amount": widget.amount,
        "purpose": widget.purpose,
        "reference_type": widget.referenceType,
        "payment_method": selectedMethod,
      };

      if (widget.referenceType == "order") {
        request["order_id"] = widget.transactionId;
      }
      if (widget.referenceType == "booking") {
        request["booking_id"] = widget.transactionId;
      }
      if (widget.referenceType == "property_unlock") {
        request["property_unlock_id"] = widget.transactionId;
      }
      if (widget.referenceType == "ticket") {
        request["ticket_purchase_id"] = widget.transactionId;
      }

      if (isMobile) {
        request.addAll({
          "phone_number": phoneController.text,
          "mobile_name": nameController.text,
        });
      }

      final res = await api.post(
        "payments/initiate_payment/",
        data: request,
        fromJson: (json) => json,
      );

      final paymentReference = res['payment_reference'];

      // =====================
      // VISA FLOW
      // =====================
      if (isVisa) {
        final checkoutUrl = res['checkout_url'];

        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          throw Exception("PayChangu did not return a valid checkout session.");
        }

        // 🌐 FLUTTER WEB FIX
        if (kIsWeb) {
          _startPolling(paymentReference);
          _showProcessingDialog();

          await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
          return;
        }

        // 📱 MOBILE APP NATIVE WEBVIEW FLOW
        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VisaPaymentWebView(
              checkoutUrl: checkoutUrl,
              onSuccess: () {
                _startPolling(paymentReference);
                _showProcessingDialog();
              },
            ),
          ),
        );
      } else {
        // =====================
        // MOBILE MONEY FLOW
        // =====================
        final checkoutUrl = res['paychangu']?['checkout_url'];

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
        }

        _startPolling(paymentReference);
        _showProcessingDialog();
      }
    } catch (e) {
      AppToast.error(
        context,
        "Payment failed: $e",
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
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
          final api = ref.read(apiClientProvider);

          final res = await api.get(
            "payments/status/$reference/",
            fromJson: (json) => PaymentStatusModel.fromJson(json),
          );

          if (res.status == "completed") {
            timer.cancel();

            final tabsShell = MainTabsScreen.of(context);

            // 1. Close processing dialog safely
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            AppToast.success(
              context,
              "Payment successful",
            );

            widget.onSuccess?.call(res);

            if (!mounted) return;

            // 2. Refresh provider before navigating
            ref.invalidate(ordersPaginationProvider);

            // 3. Switch tab context directly without resetting route stack
            if (widget.referenceType == "booking") {
              tabsShell?.navigateToMyBookings();
            } else if (widget.referenceType == "order") {
              tabsShell?.navigateToOrders();
            } else if (widget.referenceType == "property_unlock") {
              tabsShell?.navigateToMyUnlockedProperties();
            } else if (widget.referenceType == "ticket") {
              tabsShell?.navigateToMyTickets();
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
          debugPrint("Polling error: $e");
        }
      },
    );
  }

  // ======================
  // HELPER BUILDERS
  // ======================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.mangoOrange,
            AppColors.mangoOrange.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mangoOrange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            formatWithCommas(widget.amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.purpose,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentMethodCard(Map<String, dynamic> method) {
    final isSelected = selectedMethod == method['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method['value'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.mangoOrange
                : Theme.of(context).colorScheme.outline.withOpacity(0.38),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
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
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? AppColors.mangoOrange
                  : Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Payment Method",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...paymentMethods.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: paymentMethodCard(method),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentFormControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          AppTextField(
            label: 'Full Name',
            hint: 'Enter full name',
            controller: nameController,
            type: TextFieldType.text,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Phone Number',
            hint: 'e.g 0881234567',
            controller: phoneController,
            type: TextFieldType.phone,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
        ],
        if (isVisa) ...[
          const AppInfoBox(
            type: AppInfoType.info,
            icon: Icons.info_outline,
            message: "You will be redirected to secure PayChangu checkout.",
          ),
          const SizedBox(height: 24),
        ],
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : initiatePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mangoOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "Pay Now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Column(
            children: [
              Text(
                "Powered by",
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/changu.png',
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================
  // BUILD
  // ======================

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
                    _buildHeaderCard(),
                    const SizedBox(height: AppSpacing.lg),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildMethodsList(),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 5,
                            child: _buildPaymentFormControls(),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMethodsList(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildPaymentFormControls(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const WebFooter(),
          ],
        ),
      ),
    );
  }
}