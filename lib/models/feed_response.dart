import 'feed_item.dart';

class FeedResponse {
  final List<FeedItem> items;
  final String? nextCursor;
  final bool hasMore;

  FeedResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  factory FeedResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return FeedResponse(
      items: (json['results'] as List<dynamic>? ?? [])
          .map(
            (e) => FeedItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),

      nextCursor: json['next_cursor'],

      hasMore: json['next_cursor'] != null,
    );
  }
}