import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../models/feed_item.dart';
import '../../repositories/feed_repository.dart';

final feedRepositoryProvider = Provider(
  (ref) => FeedRepository(ApiClient()),
);

final homeFeedProvider =
    StateNotifierProvider<HomeFeedNotifier, AsyncValue<List<FeedItem>>>(
  (ref) => HomeFeedNotifier(
    ref.read(feedRepositoryProvider),
  ),
);

class HomeFeedNotifier
    extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final FeedRepository repo;

  HomeFeedNotifier(this.repo)
      : super(const AsyncValue.loading()) {
    load();
  }

  String? cursor;
  bool hasMore = true;
  bool loadingMore = false;

  Future<void> load() async {
    try {
      final response = await repo.getHomeFeed();

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

  Future<void> loadMore() async {
    if (loadingMore || !hasMore) return;

    loadingMore = true;

    try {
      final old =
          state.valueOrNull ?? [];

      final response =
          await repo.getHomeFeed(
        cursor: cursor,
      );

      cursor = response.nextCursor;
      hasMore = response.hasMore;

      state = AsyncValue.data([
        ...old,
        ...response.items,
      ]);
    } finally {
      loadingMore = false;
    }
  }
}