import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/delivery.dart';
import 'rider_delivery_screen.dart';
import '../../widgets/web_footer.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_scaffold.dart';
// Import your Analytics Service
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
    
    // Track when the user opens the delivery code screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.logEvent('view_delivery_code_screen');
    });
  }

  Future<void> openDelivery() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      analyticsService.logEvent('validation_failed_empty_delivery_code');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter delivery code")),
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
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: AppSpacing.md),

            // =========================
            // 🔥 INFO HEADER (NEW)
            // =========================
            AppInfoBox(
              type: AppInfoType.info,
              icon: Icons.info_outline,
              message: "Please enter the delivery code you received from the shop owner you are delivering for.",
              ),
            const SizedBox(height: 25),

            // =========================
            // INPUT FIELD
            // =========================
            AppTextField(
              label: 'Delivery Code',
              hint: 'Enter Delivery Code',
              controller:codeController,
              type: TextFieldType.text,
              isRequired: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                return null;
                },
            ),

            const SizedBox(height: AppSpacing.md),

            // =========================
            // BUTTON
            // =========================
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: loading ? "Opening..." : "Open Delivery",
                loading: loading,
                fullWidth: true,
                onPressed: openDelivery,
                ),
            ),
          ],
        ),
    );
  }
}