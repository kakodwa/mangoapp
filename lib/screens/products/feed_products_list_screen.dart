import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';

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
      data: (items) => RefreshIndicator(
        onRefresh: () async {
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
          ],
        ),
      ),
    );
  }
}