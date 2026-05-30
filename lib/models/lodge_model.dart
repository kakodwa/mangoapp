class Lodge {
  final int id;
  final String name;
  final String description;
  final String lodgeType;
  final String city;
  final String district;
  final String address;
  final String phoneNumber;
  final String email;
  final bool isVerified;
  final List<String> images;

  final double? latitude;
  final double? longitude;

  // 🔥 OWNER INFO
  final int? ownerId;
  final String? ownerPhoneNumber;

  Lodge({
    required this.id,
    required this.name,
    required this.description,
    required this.lodgeType,
    required this.city,
    required this.district,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.isVerified,
    required this.images,
    this.latitude,
    this.longitude,
    this.ownerId,
    this.ownerPhoneNumber,
  });

  factory Lodge.fromJson(Map<String, dynamic> json) {
    return Lodge(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      lodgeType: json['lodge_type'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['is_verified'] ?? false,

      images: json['images'] != null
          ? List<String>.from(
              json['images'].map((e) => e['image']),
            )
          : [],

      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,

      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,

      ownerId: json['owner_id'],
      ownerPhoneNumber: json['owner_phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'lodge_type': lodgeType,
      'city': city,
      'district': district,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'is_verified': isVerified,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
      'owner_phone_number': ownerPhoneNumber,
    };
  }
}