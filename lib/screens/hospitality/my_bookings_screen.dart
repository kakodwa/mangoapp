import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookings_provider.dart';
import '../../widgets/hospitality/booking_card.dart';

// Design System Imports
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/web_footer.dart';

// First-letter capitalization extension string utility (Preserved)
extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    // Calculate responsive framework screen metric profiles 
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppInfoBox(
                type: AppInfoType.info,
                message: "No bookings found".toCapitalized(),
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                // Adapts dynamic margins to safely center the content card stacks on desktop views
                horizontal: isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                              child: BookingCard(booking: bookings[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Layout spacer bridge ensuring nice visual padding before footer bounds appear
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),

            // ================= WEB FOOTER =================
            // Attaches to the root scrolling layout tree smoothly at the absolute viewport end
            const SliverToBoxAdapter(
              child: WebFooter(),
            ),
          ],
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
            message: e.toString().toCapitalized(),
          ),
        ),
      ),
    );
  }
}