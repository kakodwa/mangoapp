import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/properties_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../utils/app_toast.dart';

import '../payments/payment_checkout_screen.dart';
import 'property_details_screen.dart';
import '../../theme/design_system/app_spacing.dart';

class PropertyUnlockScreen extends ConsumerStatefulWidget {
  final int propertyId;
  final String propertyTitle;
  final double unlockFee;

  const PropertyUnlockScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.unlockFee,
  });

  @override
  ConsumerState<PropertyUnlockScreen> createState() =>
      _PropertyUnlockScreenState();
}

class _PropertyUnlockScreenState
    extends ConsumerState<PropertyUnlockScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Unlock Property'),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),

          /// PROPERTY CARD (UNCHANGED)
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
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
                    const SizedBox(width: AppSpacing.xs),
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
                const SizedBox(height: AppSpacing.sm),
                const Text('What you\'ll get after unlocking:'),
                const SizedBox(height: AppSpacing.xs),
                _buildFeature('Full property description and details'),
                _buildFeature('Exact location on map'),
                _buildFeature('Contact information of property owner'),
                _buildFeature('Property inspection history'),
              ],
            ),
          ),

          /// AMOUNT CARD (UNCHANGED)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
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
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mangoOrange,
                ),
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)
                    : const Icon(Icons.lock_open),
                label: Text(
                  _isProcessing
                      ? 'Preparing payment...'
                      : 'Pay & Unlock (MWK ${widget.unlockFee.toStringAsFixed(2)})',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String feature) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.mangoOrange),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(feature)),
      ],
    );
  }
}