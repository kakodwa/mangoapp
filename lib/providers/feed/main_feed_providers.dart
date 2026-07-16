// lib/providers/feed/main_feed_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../models/feed_item.dart';
import '../../repositories/feed_repository.dart';
import 'feed_notifier.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(
    ApiClient(),
  ),
);

/// HOME FEED PROVIDER
final homeFeedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo = ref.read(feedRepositoryProvider);

    return FeedNotifier(
      ({String? cursor}) => repo.getHomeFeed(cursor: cursor),
      cacheKey: 'offline_cache_home_feed', // Provided required parameter!
    );
  },
);

/// SHOPS FEED PROVIDER
final shopFeedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo = ref.read(feedRepositoryProvider);

    return FeedNotifier(
      ({String? cursor}) => repo.getShopFeed(cursor: cursor),
      cacheKey: 'offline_cache_shop_feed', // Provided required parameter!
    );
  },
);

/// EVENTS FEED PROVIDER
final eventFeedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo = ref.read(feedRepositoryProvider);

    return FeedNotifier(
      ({String? cursor}) => repo.getEventFeed(cursor: cursor),
      cacheKey: 'offline_cache_event_feed', // Provided required parameter!
    );
  },
);

/// PROPERTIES FEED PROVIDER
final propertyFeedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo = ref.read(feedRepositoryProvider);

    return FeedNotifier(
      ({String? cursor}) => repo.getPropertyFeed(cursor: cursor),
      cacheKey: 'offline_cache_property_feed', // Provided required parameter!
    );
  },
);

/// LODGES FEED PROVIDER
final lodgeFeedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>(
  (ref) {
    final repo = ref.read(feedRepositoryProvider);

    return FeedNotifier(
      ({String? cursor}) => repo.getLodgeFeed(cursor: cursor),
      cacheKey: 'offline_cache_lodge_feed', // Provided required parameter!
    );
  },
);