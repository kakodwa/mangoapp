import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookings_provider.dart';
import '../../widgets/hospitality/booking_card.dart';

// Design System Imports
import '../../theme/design_system/app_loader.dart';
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

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Triggers pagination fetch when scrolling within 300 pixels of the bottom viewport threshold
    if (currentScroll >= maxScroll - 300) {
      // NOTE: If you refactor bookingsProvider to a paginated state notifier in the future,
      // you can uncomment the line below to call your pagination engine:
      // ref.read(bookingsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);

    // Calculate responsive framework screen metric profiles 
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    final double edgePadding = isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md;

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Centered Empty State Layout with a high-quality contextual icon
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "No bookings found".toCapitalized(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Your completed and upcoming reservations will show up here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    // Web footer displays even during an empty data state payload
                    const WebFooter(),
                  ],
                ),
              ),
            ],
          );
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Standard SliverPadding + SliverList for memory efficient lazy rendering
            SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: edgePadding,
              ),
              sliver: SliverList.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: BookingCard(booking: bookings[index]),
                  );
                },
              ),
            ),
            
            // Layout spacer bridge ensuring nice visual padding before footer bounds appear
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),

            // ================= WEB FOOTER =================
            const SliverToBoxAdapter(
              child: WebFooter(),
            ),
          ],
        );
      },
      loading: () => Center(
        child: AppLoader.inline(),
      ),
      error: (e, _) => CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    e.toString().toCapitalized(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                const Spacer(),
                const WebFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}