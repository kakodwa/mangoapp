import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/feed_item.dart';
import '../../models/feed_response.dart';

typedef FeedLoader = Future<FeedResponse> Function({
  String? cursor,
});

class FeedNotifier
    extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final FeedLoader loader;

  FeedNotifier(this.loader)
      : super(const AsyncValue.loading()) {
    load();
  }

  String? cursor;
  bool hasMore = true;
  bool loadingMore = false;

  Future<void> load() async {
    try {
      final response = await loader();

      cursor = response.nextCursor;
      hasMore = response.hasMore;

      state = AsyncValue.data(
        response.items,
      );
    } catch (e, st) {
      state = AsyncValue.error(
        e,
        st,
      );
    }
  }

  Future<void> refresh() async {
    cursor = null;
    hasMore = true;

    state = const AsyncValue.loading();

    await load();
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMore) {
      return;
    }

    loadingMore = true;

    try {
      final oldItems =
          state.valueOrNull ?? [];

      final response =
          await loader(
        cursor: cursor,
      );

      cursor =
          response.nextCursor;

      hasMore =
          response.hasMore;

      state = AsyncValue.data([
        ...oldItems,
        ...response.items,
      ]);
    } catch (e, st) {
      state = AsyncValue.error(
        e,
        st,
      );
    } finally {
      loadingMore = false;
    }
  }
}