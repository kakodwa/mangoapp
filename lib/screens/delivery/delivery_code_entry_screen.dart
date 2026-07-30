// lib/screens/delivery/delivery_code_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/delivery.dart';
import '../main_tabs_screen.dart';
import 'rider_delivery_screen.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
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
        const SnackBar(content: Text("Enter the seller dispatch code")),
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

      // Triggers tab navigation inside MainTabsScreen shell
      MainTabsScreen.of(context)?.navigateToRiderDelivery(delivery);
    } catch (e) {
      analyticsService.logEvent('delivery_code_verify_failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid seller code or order not found")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, 
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= ROUNDED ORANGE HEADER CARD =================
                  _buildRoundedOrangeHeader(),

                  const SizedBox(height: AppSpacing.md),

                  // ================= BODY CONTENT =================
                  isDesktop 
                      ? _buildDesktopLayout(context) 
                      : _buildMobileLayout(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Web/Desktop Footer
          const WebFooter(),
        ],
      ),
    );
  }

  /// Top Rounded Orange Card Header
  Widget _buildRoundedOrangeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.mangoOrange,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.mangoOrange.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Seller Pickup & Delivery Verification",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Enter the secret pickup code provided by the seller to view delivery details.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile Layout (Single Column)
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rounded Orange Info Box
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.mangoOrange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.mangoOrange.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.storefront_outlined,
                color: AppColors.mangoOrange,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Step 1: Enter the seller's secret code to open order navigation. You will enter the customer's code at handover to release escrow funds.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Input Form Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildFormContent(context),
        ),
      ],
    );
  }

  /// Desktop Layout (Info Box Left, Form Right)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT SIDE: Orange Explanation Box
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.mangoOrange.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mangoOrange.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Two-Step Escrow Verification Flow",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "1. Pickup Code (Seller): Enter the secret code given by the seller when picking up package items.\n"
                  "2. Drop-off Code (Customer): On the next screen, ask the customer for their code upon delivery. This completes the order and releases money from escrow to the vendor.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Divider(color: AppColors.mangoOrange.withOpacity(0.2)),
                const SizedBox(height: 14),
                _buildHelpItem(
                  icon: Icons.inventory_2_outlined,
                  title: "Step 1: Seller Pickup",
                  description: "Confirm order items directly at the shop using the seller code.",
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  icon: Icons.payments_outlined,
                  title: "Step 2: Customer Escrow Release",
                  description: "Collect customer delivery code at handover to instantly trigger escrow payout.",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // RIGHT SIDE: Form Input Card
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Seller Pickup Code",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Input the code given by the seller to fetch order and customer navigation.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
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
          label: 'Seller Code',
          hint: 'Enter Seller Secret Code (e.g., 583921)',
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
            text: loading ? "Accessing Order..." : "Open Delivery Route",
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
        Icon(icon, size: 18, color: AppColors.mangoOrange),
        const SizedBox(width: 10),
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