import 'product_variant_model.dart'; // Make sure to import your variant model file

class Product {
  final int id;
  final int? ownerId;
  final String? shopDistrict;
  final String? shopPhoneNumber; // ✅ Added
  final int shopId;
  final String shopName;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final String category;
  final double price;
  final double? originalPrice;
  final int discountPercentage;
  final int stock;
  final String sku;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;

  // ✅ MULTIPLE IMAGES
  final List<String> images;

  // 1. Declare the variants list property
  final List<LocalProductVariant> variants;

  Product({
    required this.id,
    this.ownerId,
    required this.shopId,
    this.shopDistrict,
    this.shopPhoneNumber, // ✅ Added
    required this.shopName,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.discountPercentage,
    required this.stock,
    required this.sku,
    required this.isActive,
    required this.rating,
    required this.totalReviews,
    required this.createdAt,
    this.images = const [],
    this.variants = const [], // 2. Default to an empty list
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ??
          (throw Exception("Product ID missing from API response")),
      ownerId: json['owner_id'],
      shopId: json['shop'] ?? 0,
      shopDistrict: json['shop_district'],
      shopPhoneNumber: json['shop_phone_number'], // ✅ Added
      shopName: json['shop_name'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      category: json['category'] ?? 'Electronics',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      discountPercentage: json['discount_percentage'] ?? 0,
      stock: json['stock'] ?? 0,
      sku: json['sku'] ?? '',
      isActive: json['is_active'] ?? false,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),

      // ✅ MULTIPLE IMAGES
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      // 3. Map the JSON variants list into your variant model array
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => LocalProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'shop_district': shopDistrict,
      'shop_phone_number': shopPhoneNumber, // ✅ Added
      'shop_name': shopName,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'stock': stock,
      'sku': sku,
      'is_active': isActive,
      'rating': rating,
      'total_reviews': totalReviews,
      'created_at': createdAt.toIso8601String(),

      // ✅ IMAGES
      'images': images,

      // 4. Map variant entities back to JSON structures
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  bool get hasDiscount => discountPercentage > 0;
  bool get isInStock => stock > 0;
  bool get hasImage => image?.isNotEmpty == true;
  String get safeImage => image ?? '';

  // ✅ Convenience getter
  String get phoneNumber => shopPhoneNumber ?? '';
}