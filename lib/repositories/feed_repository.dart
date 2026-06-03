import '../core/api/api_client.dart';
import '../models/feed_response.dart';

class FeedRepository {
  final ApiClient api;

  FeedRepository(this.api);

  Future<FeedResponse> getHomeFeed({
    String? cursor,
  }) async {
    return api.get(
      'feed/home/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
      },
      fromJson: FeedResponse.fromJson,
    );
  }

  Future<FeedResponse> getShopFeed({
    String? cursor,
  }) async {
    return api.get(
      'feed/shops/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
      },
      fromJson: FeedResponse.fromJson,
    );
  }

  Future<FeedResponse> getEventFeed({
    String? cursor,
  }) async {
    return api.get(
      'feed/events/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
      },
      fromJson: FeedResponse.fromJson,
    );
  }

  Future<FeedResponse> getPropertyFeed({
    String? cursor,
  }) async {
    return api.get(
      'feed/properties/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
      },
      fromJson: FeedResponse.fromJson,
    );
  }

  Future<FeedResponse> getLodgeFeed({
    String? cursor,
  }) async {
    return api.get(
      'feed/lodges/',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
      },
      fromJson: FeedResponse.fromJson,
    );
  }
}