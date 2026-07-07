import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/web_footer.dart';
import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';

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