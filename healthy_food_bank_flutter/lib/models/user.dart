enum UserRole { CUSTOMER, VENDOR, ADMIN }

class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final UserRole role;
  final String? vendorId;
  final String userName;
  final String? password;
  final bool? active;
  final int? pickupPointId;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    required this.role,
    this.vendorId,
    required this.userName,
    this.password,
    this.active,
    this.pickupPointId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber']?.toString(),
      role: _parseRole(json['roles']?.toString() ?? json['role']?.toString() ?? 'CUSTOMER'),
      vendorId: json['vendorId']?.toString(),
      userName: json['userName'] ?? json['username'] ?? '',
      active: json['active'],
      pickupPointId: json['pickupPointId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'roles': role.toString().split('.').last,
      if (vendorId != null) 'vendorId': vendorId,
      'userName': userName,
      if (password != null) 'password': password,
      if (pickupPointId != null) 'pickupPointId': pickupPointId,
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  bool get isVendor => role == UserRole.VENDOR;
  bool get isCustomer => role == UserRole.CUSTOMER;
  bool get isAdmin => role == UserRole.ADMIN;

  static UserRole _parseRole(String role) {
    // Remove ROLE_ prefix if present (Spring Security format)
    final cleanRole = role.toUpperCase().replaceAll('ROLE_', '');
    switch (cleanRole) {
      case 'VENDOR':
        return UserRole.VENDOR;
      case 'ADMIN':
        return UserRole.ADMIN;
      default:
        return UserRole.CUSTOMER;
    }
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? vendorId,
    String? userName,
    int? pickupPointId,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      vendorId: vendorId ?? this.vendorId,
      userName: userName ?? this.userName,
      active: active,
      pickupPointId: pickupPointId ?? this.pickupPointId,
    );
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'userName': username,
        'password': password,
      };
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json),
    );
  }
}
