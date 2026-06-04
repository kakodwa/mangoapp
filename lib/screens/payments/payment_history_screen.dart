import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/app_scaffold.dart';

// Safe first-letter-only capitalization extension
extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Payment history',
        ),
      ),
      body: paymentsAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return Center(
              child: AppInfoBox(
                type: AppInfoType.info,
                message: "No payments found".toCapitalized(),
              ),
            );
          }

          return ListView.builder(
            itemCount: payments.length,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            itemBuilder: (context, index) {
              final payment = payments[index];
              final bool isCompleted = payment.status == "completed";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Icon
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.pending,
                        color: isCompleted ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Content Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Amount text (Keeping currency code standard but content capitalized)
                            Text(
                              "MWK ${payment.amount}",
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),

                            // Details / Metadata
                            Text(
                              payment.purposeDisplay.toCapitalized(),
                              style: AppTypography.bodyMedium,
                            ),
                            Text(
                              payment.paymentMethodDisplay.toCapitalized(),
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (payment.orderNumber != null) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                "Order: ${payment.orderNumber}".toCapitalized(),
                                style: AppTypography.bodySmall,
                              ),
                            ],
                            if (payment.propertyTitle != null) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                payment.propertyTitle!.toCapitalized(),
                                style: AppTypography.bodySmall,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xs),
                            
                            // Reference string
                            Text(
                              payment.paymentReference.toCapitalized(),
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Status Badge
                      AppBadge(
                        text: payment.statusDisplay.toCapitalized(),
                        type: isCompleted ? BadgeType.success : BadgeType.warning,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: AppLoader.inline(),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInfoBox(
              type: AppInfoType.error,
              message: "Error: ${e.toString()}".toCapitalized(),
            ),
          ),
        ),
      ),
    );
  }
}