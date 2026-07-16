// lib/providers/feed/feed_notifier.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/feed_item.dart';
import '../../models/feed_response.dart';

typedef FeedLoader = Future<FeedResponse> Function({
  String? cursor,
});

class FeedNotifier extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final FeedLoader loader;
  final String cacheKey; // Required for mapping the storage partitions

  FeedNotifier(this.loader, {required this.cacheKey})
      : super(const AsyncValue.loading()) {
    initAndLoad();
  }

  String? cursor;
  bool hasMore = true;
  bool loadingMore = false;

  /// Loads cached local feed instantly, then triggers background sync
  Future<void> initAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);

    if (cachedJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(cachedJson);
        final cachedItems = decodedList
            .map((e) => FeedItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        
        // Show cached stream to the UI instantly
        state = AsyncValue.data(cachedItems);
      } catch (e) {
        state = const AsyncValue.loading();
      }
    }

    await load(isBackgroundFetch: cachedJson != null);
  }

  Future<void> load({bool isBackgroundFetch = false}) async {
    try {
      final response = await loader();

      cursor = response.nextCursor;
      hasMore = response.hasMore;

      state = AsyncValue.data(response.items);

      // Save raw map data directly to local memory 
      final prefs = await SharedPreferences.getInstance();
      
      // Map properties that actually exist on a FeedItem for feed UI layout consistency
      final rawListToCache = response.items.map((item) {
        return {
          'type': item.type,
          'data': item.data,
          'title': item.title,
          'view_all_type': item.viewAllType,
        };
      }).toList();

      await prefs.setString(cacheKey, jsonEncode(rawListToCache));

    } catch (e, st) {
      if (!isBackgroundFetch) {
        state = AsyncValue.error(e, st);
      }
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
      final oldItems = state.valueOrNull ?? [];
      final response = await loader(
        cursor: cursor,
      );

      cursor = response.nextCursor;
      hasMore = response.hasMore;

      state = AsyncValue.data([
        ...oldItems,
        ...response.items,
      ]);
    } catch (e, st) {
      // Preserve current screen state if pagination fails on poor connection
    } finally {
      loadingMore = false;
    }
  }
}