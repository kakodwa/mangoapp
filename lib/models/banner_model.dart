class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? url;
  final String ctaText;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaText,
    this.url,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'],
      url: json['url'],
      ctaText: (json['cta_text'] ?? 'Learn more').toString(),
    );
  }
}