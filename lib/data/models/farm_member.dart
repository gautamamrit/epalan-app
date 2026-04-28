/// Farm member — a user with a role on a farm
class FarmMember {
  final String id; // membership ID
  final String userId;
  final MemberUser user;
  final String role;
  final DateTime createdAt;

  FarmMember({
    required this.id,
    required this.userId,
    required this.user,
    required this.role,
    required this.createdAt,
  });

  factory FarmMember.fromJson(Map<String, dynamic> json) {
    return FarmMember(
      id: json['id'],
      userId: json['userId'],
      user: MemberUser.fromJson(json['user']),
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}

/// Minimal user info returned with memberships
class MemberUser {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? email;
  final String? phone;

  MemberUser({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.email,
    this.phone,
  });

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  String get initials => '${firstName[0]}${lastName[0]}';

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      id: json['id'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

/// Pending invite to a farm
class FarmInvite {
  final String id;
  final String inviteType; // 'phone' | 'email'
  final String inviteValue;
  final String role;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;

  FarmInvite({
    required this.id,
    required this.inviteType,
    required this.inviteValue,
    required this.role,
    required this.status,
    this.expiresAt,
    required this.createdAt,
  });

  factory FarmInvite.fromJson(Map<String, dynamic> json) {
    return FarmInvite(
      id: json['id'],
      inviteType: json['inviteType'] ?? 'email',
      inviteValue: json['inviteValue'] ?? '',
      role: json['role'] ?? 'staff',
      status: json['status'] ?? 'pending',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'].toString())
          : null,
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}
