// lib/screens/properties/property_unlock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../providers/api_provider.dart';
import '../../providers/properties_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';

import '../main_tabs_screen.dart'; // ✅ Added to access master tab router framework engine
import '../payments/payment_checkout_screen.dart';
import 'property_details_screen.dart';
import '../../theme/design_system/app_spacing.dart';

// Analytics Import
import '../../services/analytics_service.dart';
import '../../widgets/web_footer.dart';

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
  bool _hasLoggedView = false;

  /// default method (backend will still receive from payment screen)
  final String _selectedPaymentMethod = 'airtel_money';

  /// ================= CREATE UNLOCK THEN GO TO PAYMENT =================
  Future<void> _processPayment() async {
    final AnalyticsService analytics = AnalyticsService();
    
    analytics.logEvent('property_unlock_initiate');

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

      /// 2️⃣ NAVIGATE TO PAYMENT SCREEN (VIA MAIN TABS ROUTER LAYER)
      final tabsScreen = MainTabsScreen.of(context);

      if (tabsScreen != null) {
        // ✅ FIXED: Routes seamlessly inside the nested tab view index 42 matching standard checkout_screen.dart implementations
        tabsScreen.navigateToPayment(
          transactionId: unlockId,
          amount: widget.unlockFee,
          purpose: "property_unlock",
          referenceType: "property_unlock",
          onSuccess: (_) {
            analytics.logEvent('property_unlock_success');

            AppToast.success(
              context,
              'Property unlocked successfully',
            );

            ref.invalidate(
              propertyDetailsProvider(widget.propertyId),
            );

            // Re-render core property tracking views safely
            tabsScreen.navigateToPropertyDetails(widget.propertyId);
          },
        );
      } else {
        // Fallback layout execution framework matrix if host container context isn't matched
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentCheckoutScreen(
              transactionId: unlockId,
              amount: widget.unlockFee,
              purpose: "property_unlock",
              referenceType: "property_unlock",
              onSuccess: (_) {
                analytics.logEvent('property_unlock_success');

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
      }
    } catch (e) {
      AppToast.error(context, 'Failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AnalyticsService analytics = AnalyticsService();

    if (!_hasLoggedView) {
      analytics.logEvent('property_unlock_view');
      _hasLoggedView = true;
    }

    return Container(
      color: const Color(0xFFF5F7FA),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PROPERTY CARD
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
                            const Icon(Icons.lock, color: AppColors.mangoOrange),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                widget.propertyTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'What you\'ll get after unlocking:',
                          style: TextStyle(fontSize: 14, color: Colors.black87, decoration: TextDecoration.none, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildFeature('Full property description and details'),
                        _buildFeature('Exact location on map'),
                        _buildFeature('Contact information of property owner'),
                        _buildFeature('Property inspection history'),
                      ],
                    ),
                  ),

                  /// AMOUNT CARD
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
                          const Text(
                            'Unlock Fee:',
                            style: TextStyle(fontSize: 14, color: Colors.black87, decoration: TextDecoration.none, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'MWK ${widget.unlockFee.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.mangoOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// BUTTON
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mangoOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isProcessing ? null : _processPayment,
                        icon: _isProcessing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.surface, strokeWidth: 2),
                              )
                            : const Icon(Icons.lock_open),
                        label: Text(
                          _isProcessing
                              ? 'Preparing payment...'
                              : 'Pay & Unlock (MWK ${widget.unlockFee.toStringAsFixed(2)})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: WebFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.mangoOrange, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 13, color: Colors.black87, decoration: TextDecoration.none, fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}