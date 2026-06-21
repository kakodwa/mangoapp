import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';
import '../../widgets/web_footer.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({
    super.key,
  });

  @override
  ConsumerState<ProductsListScreen> createState() =>
      _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final ScrollController _controller = ScrollController();
  
  // Track viewed state to avoid duplicate triggers during local state changes
  bool _hasLoggedView = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }

    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.position.pixels;

    if (currentScroll >= maxScroll - 300) {
      ref.read(homeFeedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final AnalyticsService analytics = AnalyticsService();

    // Returning content directly lets IndexedStack manage the scroll state
    return feed.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, st) => Center(
        child: Text(
          e.toString(),
        ),
      ),
      data: (items) {
        // 📊 TRACK EVENT: Initial feed items have loaded and rendered to view
        if (!_hasLoggedView) {
          analytics.logEvent('feed_products_view');
          _hasLoggedView = true;
        }

        return RefreshIndicator(
          onRefresh: () async {
            // 📊 TRACK EVENT: User pulls to refresh the main product feed
            analytics.logEvent('feed_products_refresh');
            
            await ref.read(homeFeedProvider.notifier).refresh();
          },
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              FeedListWidget(
                items: items,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ref.watch(homeFeedProvider.notifier).loadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: WebFooter(),
                ),
            ],
          ),
        );
      },
    );
  }
}