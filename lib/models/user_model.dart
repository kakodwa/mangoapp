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
      isVerified: json['is_verified'] ?? false,
      dateJoined: DateTime.parse(json['date_joined'] ?? DateTime.now().toIso8601String()),
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
      'is_verified': isVerified,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

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
      isVerified: isVerified ?? this.isVerified,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }
}
