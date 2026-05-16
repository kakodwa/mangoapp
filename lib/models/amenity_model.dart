class Amenity {
  final int id;
  final String name;
  final String? icon;

  Amenity({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}