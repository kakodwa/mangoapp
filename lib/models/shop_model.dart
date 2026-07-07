class Shop {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String logo;
  final String? banner;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String district;
  final String phoneNumber;
  final String email;
  final String status;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;
  final int? productCount;
  final String? qrCode;       
  final int? qrScanCount; 

  Shop({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.logo,
    this.banner,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.district,
    required this.phoneNumber,
    required this.email,
    required this.status,
    required this.isActive,
    required this.rating,
    required this.totalReviews,
    required this.createdAt,
    this.productCount,
    this.qrCode,
    this.qrScanCount,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      banner: json['banner'],
      category: json['category'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      isActive: json['is_active'] ?? false,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      productCount: json['product_count'],
      qrCode: json['qr_code'],                              
      qrScanCount: json['qr_scan_count'] != null 
          ? int.tryParse(json['qr_scan_count'].toString()) 
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logo': logo,
      'banner': banner,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'district': district,
      'phone_number': phoneNumber,
      'email': email,
      'status': status,
      'is_active': isActive,
      'rating': rating,
      'total_reviews': totalReviews,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
