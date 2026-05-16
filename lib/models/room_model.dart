class Room {
  final int id;
  final int lodge;

  /// ✅ OWNER
  final int? ownerId;
  final String? ownerUsername;
  final bool isOwner;

  final String roomType;
  final String roomNumber;
  final String title;
  final String description;
  final double pricePerNight;
  final int capacity;

  final bool hasWifi;
  final bool hasTv;
  final bool hasAc;
  final bool hasBreakfast;

  final bool isAvailable;

  Room({
    required this.id,
    required this.lodge,

    /// OWNER
    this.ownerId,
    this.ownerUsername,
    this.isOwner = false,

    required this.roomType,
    required this.roomNumber,
    required this.title,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.hasWifi,
    required this.hasTv,
    required this.hasAc,
    required this.hasBreakfast,
    required this.isAvailable,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      lodge: json['lodge'],

      /// ✅ OWNER DATA FROM API
      ownerId: json['owner_id'],
      ownerUsername: json['owner_username'],
      isOwner: json['is_owner'] ?? false,

      roomType: json['room_type'] ?? '',
      roomNumber: json['room_number'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pricePerNight:
          double.tryParse(json['price_per_night'].toString()) ?? 0,
      capacity: json['capacity'] ?? 1,
      hasWifi: json['has_wifi'] ?? false,
      hasTv: json['has_tv'] ?? false,
      hasAc: json['has_ac'] ?? false,
      hasBreakfast: json['has_breakfast'] ?? false,
      isAvailable: json['is_available'] ?? false,
    );
  }
}