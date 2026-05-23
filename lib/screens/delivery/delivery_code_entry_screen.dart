import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/delivery.dart';
import 'rider_delivery_screen.dart';
<<<<<<< HEAD

import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_text_field.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_button.dart';
import '../../widgets/app_scaffold.dart';
=======
import '../../theme/design_system/app_button.dart';
import '../../theme/design_system/app_info_box.dart';
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class DeliveryCodeScreen extends ConsumerStatefulWidget {
  const DeliveryCodeScreen({super.key});

  @override
  ConsumerState<DeliveryCodeScreen> createState() =>
      _DeliveryCodeScreenState();
}

class _DeliveryCodeScreenState extends ConsumerState<DeliveryCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;

  Future<void> openDelivery() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter delivery code")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      final delivery = await api.post(
        "deliveries/open_by_code/",
        data: {"code": code},
        fromJson: (json) => Delivery.fromJson(json),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RiderDeliveryScreen(delivery: delivery),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code or server error")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return AppScaffold(
=======
    return Scaffold(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Enter Delivery Code"),
        backgroundColor: AppColors.primary(context),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

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
<<<<<<< HEAD
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
=======
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: "Delivery Code",
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
            ),

            const SizedBox(height: 20),

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
      ),
    );
  }
}