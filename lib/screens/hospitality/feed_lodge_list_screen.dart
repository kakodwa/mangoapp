import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';

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
                  child: ref.watch(lodgeFeedProvider.notifier).loadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}