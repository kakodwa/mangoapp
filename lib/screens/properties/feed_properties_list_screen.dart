import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../widgets/feed/feed_list_widget.dart';

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
      data: (items) => RefreshIndicator(
        onRefresh: () async {
          await ref.read(propertyFeedProvider.notifier).refresh();
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
                  child: ref.watch(propertyFeedProvider.notifier).loadingMore
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