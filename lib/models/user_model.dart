class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;

  // ======================
  // NEW FIELDS
  // ======================
  final String? gender;
  final String? district;
  final DateTime? dateOfBirth;

  final bool isVerified;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
    this.gender,
    this.district,
    this.dateOfBirth,
    required this.isVerified,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userType: json['user_type'] ?? 'customer',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],

      // NEW FIELDS
      gender: json['gender'],
      district: json['district'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,

      isVerified: json['is_verified'] ?? false,
      dateJoined: DateTime.parse(
        json['date_joined'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'bio': bio,

      // NEW FIELDS
      'gender': gender,
      'district': district,
      'date_of_birth': dateOfBirth != null
          ? "${dateOfBirth!.year.toString().padLeft(4, '0')}-"
              "${dateOfBirth!.month.toString().padLeft(2, '0')}-"
              "${dateOfBirth!.day.toString().padLeft(2, '0')}"
          : null,

      'is_verified': isVerified,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  String? get dateOfBirthString {
    if (dateOfBirth == null) return null;

    return "${dateOfBirth!.year.toString().padLeft(4, '0')}-"
        "${dateOfBirth!.month.toString().padLeft(2, '0')}-"
        "${dateOfBirth!.day.toString().padLeft(2, '0')}";
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? userType,
    String? phoneNumber,
    String? profilePicture,
    String? bio,
    String? gender,
    String? district,
    DateTime? dateOfBirth,
    bool? isVerified,
    DateTime? dateJoined,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,

      // NEW FIELDS
      gender: gender ?? this.gender,
      district: district ?? this.district,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,

      isVerified: isVerified ?? this.isVerified,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }
}