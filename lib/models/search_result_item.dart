class SearchResultItem {
  final int id;
  final String resultType;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final double? price;
  final String? city;
  final String? district;
  final Map<String, dynamic> details;

  SearchResultItem({
    required this.id,
    required this.resultType,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.price,
    this.city,
    this.district,
    required this.details,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] as int,
      resultType: json['result_type'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String?,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      city: json['city'] as String?,
      district: json['district'] as String?,
      details: json['details'] is Map<String, dynamic> ? json['details'] as Map<String, dynamic> : {},
    );
  }
}