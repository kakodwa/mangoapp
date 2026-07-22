// 1. Flutter Core Packages
import 'package:flutter/material.dart';

// 2. Third-Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. Project Imports

// Providers
import '../../providers/feed/main_feed_providers.dart';

// Widgets
import '../../widgets/feed/feed_list_widget.dart';
import '../../widgets/web_footer.dart';

// Analytics & Services
import '../../services/analytics_service.dart';

import '../../screens/search/global_search_input_bar.dart';
import '../../screens/search/unified_search_screen.dart';

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
          child: items.isEmpty
              ? CustomScrollView(
                  // physics ensures pull-to-refresh still works when empty
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 72,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Products Found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'There are no items to display at the moment. Pull down to refresh and try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  controller: _controller,
                  slivers: [
                    GlobalSearchInputBar.sliver(),
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