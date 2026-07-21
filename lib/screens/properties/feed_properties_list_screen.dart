import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';

// Analytics Import
import '../../services/analytics_service.dart';
import '../../widgets/web_footer.dart';

class PropertiesListScreen extends ConsumerStatefulWidget {
  const PropertiesListScreen({
    super.key,
  });

  @override
  ConsumerState<PropertiesListScreen> createState() =>
      _PropertiesListScreenState();
}

class _PropertiesListScreenState extends ConsumerState<PropertiesListScreen> {
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
      ref.read(propertyFeedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up memory leaks cleanly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(propertyFeedProvider);
    final AnalyticsService analytics = AnalyticsService();

    // Returning content directly lets IndexedStack handle the view persistence seamlessly
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
        // 📊 TRACK EVENT: Real estate feed items have successfully loaded and rendered
        if (!_hasLoggedView) {
          analytics.logEvent('feed_properties_view');
          _hasLoggedView = true;
        }

        return RefreshIndicator(
          onRefresh: () async {
            // 📊 TRACK EVENT: User pulls down to manual refresh the properties feed
            analytics.logEvent('feed_properties_refresh');

            await ref.read(propertyFeedProvider.notifier).refresh();
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
                                Icons.real_estate_agent_outlined, // Real estate icon
                                size: 72,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Properties Found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'There are no active property listings available right now. Pull down to refresh and try again.',
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
                    FeedListWidget(
                      items: items,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: ref.watch(propertyFeedProvider.notifier).loadingMore
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