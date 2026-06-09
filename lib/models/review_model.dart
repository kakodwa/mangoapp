class Review {
  final int id;
  final String userName;
  final int rating;
  final String title;
  final String comment;
  final String entityType; // e.g., 'product', 'event', 'shop'
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.entityType,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? 'Anonymous',
      rating: json['rating'] ?? 5,
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      entityType: json['entity_type'] ?? '',
      // ✅ Safe fallback ensures your app never crashes on date parsing flaws
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  // 📝 Useful for state debugging and local tracking serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'rating': rating,
      'title': title,
      'comment': comment,
      'entity_type': entityType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}