import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';
import '../../widgets/web_footer.dart';

import '../../screens/search/global_search_input_bar.dart';
import '../../screens/search/unified_search_screen.dart';

class LodgeListScreen extends ConsumerStatefulWidget {
  const LodgeListScreen({
    super.key,
  });

  @override
  ConsumerState<LodgeListScreen> createState() => _LodgeListScreenState();
}

class _LodgeListScreenState extends ConsumerState<LodgeListScreen> {
  final ScrollController _controller = ScrollController();

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
      ref.read(lodgeFeedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Prevent background memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(lodgeFeedProvider);

    // Content is delivered bare to let the root MainTabsScreen handle state caching
    return feed.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, st) => Center(
        child: Text(
          e.toString(),
        ),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () async {
          await ref.read(lodgeFeedProvider.notifier).refresh();
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
                              Icons.gite_outlined, // Clean lodge/cabin style icon
                              size: 72,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Lodges Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no lodges available right now. Pull down to refresh and check again.',
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
                        child: ref.watch(lodgeFeedProvider.notifier).loadingMore
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
      ),
    );
  }
}