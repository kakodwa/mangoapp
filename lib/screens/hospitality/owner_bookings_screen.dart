// lib/screens/hospitality/owner_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/owner_bookings_provider.dart';
import '../../widgets/hospitality/owner_booking_card.dart';
import '../../widgets/web_footer.dart';
import '../../theme/design_system/app_spacing.dart';

class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  ConsumerState<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends ConsumerState<OwnerBookingsScreen> {
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

    // Trigger pagination when scrolling within 300 pixels of the bottom threshold
    if (currentScroll >= maxScroll - 300) {
      // NOTE: If your ownerBookingsProvider supports pagination hooks in the future,
      // you can call the pagination framework engine trigger here:
      // ref.read(ownerBookingsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(ownerBookingsProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    final double horizontalPadding = isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md;

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Icon(
                      Icons.book_online_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "No bookings found",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
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
            SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: horizontalPadding,
              ),
              sliver: SliverList.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: OwnerBookingCard(booking: bookings[index]),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
            const SliverToBoxAdapter(
              child: WebFooter(),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                Text(
                  e.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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