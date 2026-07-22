import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/web_footer.dart';
import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';

import '../../screens/search/global_search_input_bar.dart';
import '../../screens/search/unified_search_screen.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({
    super.key,
  });

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
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
      ref.read(eventFeedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Avoid memory leaks on screen teardown
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(eventFeedProvider);

    // Returning content directly lets IndexedStack manage the scroll state perfectly
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
          await ref.read(eventFeedProvider.notifier).refresh();
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
                              Icons.calendar_today_outlined,
                              size: 72,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Events Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no upcoming events scheduled right now. Pull down to refresh and check again.',
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
                        child: ref.watch(eventFeedProvider.notifier).loadingMore
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