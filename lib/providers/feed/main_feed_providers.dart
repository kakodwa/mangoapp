import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../models/feed_item.dart';
import '../../repositories/feed_repository.dart';
import 'feed_notifier.dart';

final feedRepositoryProvider =
    Provider<FeedRepository>(
  (ref) => FeedRepository(
    ApiClient(),
  ),
);

/// HOME

final homeFeedProvider =
    StateNotifierProvider<
        FeedNotifier,
        AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo =
        ref.read(
      feedRepositoryProvider,
    );

    return FeedNotifier(
      ({
        String? cursor,
      }) =>
          repo.getHomeFeed(
        cursor: cursor,
      ),
    );
  },
);

/// SHOPS

final shopFeedProvider =
    StateNotifierProvider<
        FeedNotifier,
        AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo =
        ref.read(
      feedRepositoryProvider,
    );

    return FeedNotifier(
      ({
        String? cursor,
      }) =>
          repo.getShopFeed(
        cursor: cursor,
      ),
    );
  },
);

/// EVENTS

final eventFeedProvider =
    StateNotifierProvider<
        FeedNotifier,
        AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo =
        ref.read(
      feedRepositoryProvider,
    );

    return FeedNotifier(
      ({
        String? cursor,
      }) =>
          repo.getEventFeed(
        cursor: cursor,
      ),
    );
  },
);

/// PROPERTIES

final propertyFeedProvider =
    StateNotifierProvider<
        FeedNotifier,
        AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo =
        ref.read(
      feedRepositoryProvider,
    );

    return FeedNotifier(
      ({
        String? cursor,
      }) =>
          repo.getPropertyFeed(
        cursor: cursor,
      ),
    );
  },
);

/// LODGES

final lodgeFeedProvider =
    StateNotifierProvider<
        FeedNotifier,
        AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo =
        ref.read(
      feedRepositoryProvider,
    );

    return FeedNotifier(
      ({
        String? cursor,
      }) =>
          repo.getLodgeFeed(
        cursor: cursor,
      ),
    );
  },
);