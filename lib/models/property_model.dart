class PropertyImage {
  final int id;
  final String image;
  final String? altText;
  final bool isPrimary;

  PropertyImage({
    required this.id,
    required this.image,
    this.altText,
    required this.isPrimary,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      altText: json['alt_text'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'alt_text': altText,
      'is_primary': isPrimary,
    };
  }
}




class Property {
  final int id;
  final int ownerId;
  final String title;
  final String slug;
  final String description;
  final String propertyType;

  final String listingPurpose;

  final String status;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String district;
  final int? bedrooms;
  final int? bathrooms;
  final double sizeSqm;
  final double price;
  final String currency;
  final bool isPubliclyVisible;
  final double unlockFee;
  final int viewCount;
  final List<PropertyImage> images;
  final String ownerName;
  final bool isUnlocked;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.slug,
    required this.description,
    required this.propertyType,


    required this.listingPurpose,

    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.district,
    this.bedrooms,
    this.bathrooms,
    required this.sizeSqm,
    required this.price,
    required this.currency,
    required this.isPubliclyVisible,
    required this.unlockFee,
    required this.viewCount,
    required this.images,
    required this.ownerName,
    required this.isUnlocked,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      propertyType: json['property_type'] ?? 'house',

  
      listingPurpose: json['listing_purpose'] ?? 'sale',

      status: json['status'] ?? 'available',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      sizeSqm: double.tryParse(json['size_sqm'].toString()) ?? 0.0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'MWK',
      isPubliclyVisible: json['is_publicly_visible'] ?? false,
      unlockFee: double.tryParse(json['unlock_fee'].toString()) ?? 0.0,
      viewCount: json['view_count'] ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => PropertyImage.fromJson(img))
              .toList() ??
          [],
      ownerName: json['owner_name'] ?? '',
      isUnlocked: json['is_unlocked'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'property_type': propertyType,

      
      'listing_purpose': listingPurpose,

      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'district': district,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'size_sqm': sizeSqm,
      'price': price,
      'currency': currency,
      'is_publicly_visible': isPubliclyVisible,
      'unlock_fee': unlockFee,
      'view_count': viewCount,
      'images': images.map((e) => e.toJson()).toList(),
      'owner_name': ownerName,
      'is_unlocked': isUnlocked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get priceFormatted => 'MWK $price';
}