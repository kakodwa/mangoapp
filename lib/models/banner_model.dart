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
      // Safeguard ID parsing
      id: json['id'] ?? 0,
      
      // Safeguard Title (fallback to empty string if null)
      title: json['title'] ?? '',
      
      // Safeguard Subtitle
      subtitle: json['subtitle'] ?? '',
      
      // Safeguard Image URL (fallback to empty string or a placeholder path)
      imageUrl: json['image_url'] ?? '',
      
      // Explicitly allow null for url since it's defined as String?
      url: json['url'],
      
      // Clean safety cast for CTA text
      ctaText: (json['cta_text'] ?? 'Learn more').toString(),
    );
  }

  // Helper getter to cleanly check if an image path exists before loading it in the UI
  bool get hasValidImage => imageUrl.isNotEmpty && imageUrl.startsWith('http');
}