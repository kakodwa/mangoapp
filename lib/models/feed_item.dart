import 'product_model.dart';

class FeedItem {
  final String type;
  final dynamic data;

  final String? title;
  final String? viewAllType;

  FeedItem({
    required this.type,
    required this.data,
    this.title,
    this.viewAllType,
  });

  factory FeedItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'] ?? '';
    final data = json['data'];

    return FeedItem(
      type: type,
      data: data,
      title: json['title'],
      viewAllType: json['view_all_type'],
    );
  }
}