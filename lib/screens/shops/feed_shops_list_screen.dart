import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../providers/feed/feed_notifier.dart';

import '../../widgets/feed/feed_list_widget.dart';
import '../../widgets/web_footer.dart';

class ShopsListScreen extends ConsumerStatefulWidget {
  const ShopsListScreen({
    super.key,
  });

  @override
  ConsumerState<ShopsListScreen> createState() => _ShopsListScreenState();
}

class _ShopsListScreenState extends ConsumerState<ShopsListScreen> {
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
      ref.read(shopFeedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up controller memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(shopFeedProvider);

    // Returning content directly without AppScaffold wraps it beautifully into the parent's IndexedStack
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
          await ref.read(shopFeedProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            FeedListWidget(
              items: items,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Center(
                  child: ref.watch(shopFeedProvider.notifier).loadingMore
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