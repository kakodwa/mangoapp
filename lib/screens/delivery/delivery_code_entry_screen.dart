import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/delivery.dart';
import 'rider_delivery_screen.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/web_footer.dart';
import '../../services/analytics_service.dart';

class DeliveryCodeScreen extends ConsumerStatefulWidget {
  const DeliveryCodeScreen({super.key});

  @override
  ConsumerState<DeliveryCodeScreen> createState() =>
      _DeliveryCodeScreenState();
}

class _DeliveryCodeScreenState extends ConsumerState<DeliveryCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final AnalyticsService analyticsService = AnalyticsService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.logEvent('view_delivery_code_screen');
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> openDelivery() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      analyticsService.logEvent('validation_failed_empty_delivery_code');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter delivery confirmation code")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      analyticsService.logEvent('submit_delivery_code_verification');
      final api = ref.read(apiClientProvider);

      final delivery = await api.post(
        "deliveries/open_by_code/",
        data: {"code": code},
        fromJson: (json) => Delivery.fromJson(json),
      );

      analyticsService.logEvent('delivery_code_verify_success_id_${delivery.id}');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RiderDeliveryScreen(delivery: delivery),
        ),
      );
    } catch (e) {
      analyticsService.logEvent('delivery_code_verify_failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code or server error")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
            ),
          ),
          const SizedBox(height: 40),

          // Web/Desktop Footer
          const WebFooter(),
        ],
      ),
    );
  }

  /// Mobile Layout (Single Column)
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),

        // Info Banner
        AppInfoBox(
          type: AppInfoType.info,
          icon: Icons.shield_outlined,
          message:
              "Enter the delivery code provided by the customer upon handover to complete the transaction and release payment from escrow.",
        ),
        const SizedBox(height: 25),

        // Input Form
        _buildFormContent(context),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Desktop Layout (Message on Left, Form/Content on Right)
  Widget _buildDesktopLayout(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================
        // LEFT SIDE: Escrow & Verification Explanation
        // ===================================
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Confirm Delivery & Escrow Release",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "How Order Confirmation Works",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Upon receiving and inspecting their package, the customer shares their unique confirmation code with the rider or vendor. Entering this code verifies that the item has been delivered and triggers the immediate release of funds from escrow to the seller.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.verified_user_outlined,
                  title: "Protected Transactions",
                  description: "Escrow holds funds securely until the customer verifies they have received the correct item.",
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.timer_outlined,
                  title: "Auto-Release Policy",
                  description: "If the customer receives the item but does not share the code or raise a dispute, funds are automatically released to the seller after 2 days.",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 40),

        // ===================================
        // RIGHT SIDE: Code Submission Form
        // ===================================
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Customer Delivery Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Input the code provided by the customer to complete delivery and release payment.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFormContent(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Customer Delivery Code',
          hint: 'Enter Code (e.g., 893021)',
          controller: codeController,
          type: TextFieldType.text,
          isRequired: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: loading ? "Confirming..." : "Confirm & Release Escrow",
            loading: loading,
            fullWidth: true,
            onPressed: openDelivery,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}