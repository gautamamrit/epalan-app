/// User model
class User {
  final String id;
  final String? email;
  final String? phone;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String status;
  final List<String> types;
  final String language;
  final DateTime createdAt;
  final List<Membership>? memberships;

  User({
    required this.id,
    this.email,
    this.phone,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.status,
    required this.types,
    required this.language,
    required this.createdAt,
    this.memberships,
  });

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      status: json['status'],
      types: List<String>.from(json['types'] ?? []),
      language: json['language'] ?? 'ne',
      createdAt: _parseDate(json['createdAt']),
      memberships: json['memberships'] != null
          ? (json['memberships'] as List)
              .map((m) => Membership.fromJson(m))
              .toList()
          : null,
    );
  }

  /// Parse date from various formats
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      // Try ISO 8601 first
      try {
        return DateTime.parse(value);
      } catch (_) {
        // Handle JS Date.toString() format: "Sun Mar 29 2026 08:58:33 GMT+0000"
        try {
          final months = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
          };
          // Remove parentheses content and parse
          final cleaned = value.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
          final parts = cleaned.split(' ');
          if (parts.length >= 5) {
            final month = months[parts[1]] ?? 1;
            final day = int.tryParse(parts[2]) ?? 1;
            final year = int.tryParse(parts[3]) ?? DateTime.now().year;
            final timeParts = parts[4].split(':');
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;
            final second = int.tryParse(timeParts[2]) ?? 0;
            return DateTime.utc(year, month, day, hour, minute, second);
          }
        } catch (_) {}
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'status': status,
      'types': types,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'memberships': memberships?.map((m) => m.toJson()).toList(),
    };
  }
}

/// User membership
class Membership {
  final String entityType;
  final String entityId;
  final String role;

  Membership({
    required this.entityType,
    required this.entityId,
    required this.role,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      entityType: json['entityType'],
      entityId: json['entityId'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'entityId': entityId,
      'role': role,
    };
  }
}

/// Auth response
class AuthResponse {
  final User user;
  final List<Membership> memberships;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  AuthResponse({
    required this.user,
    required this.memberships,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      memberships: (json['memberships'] as List)
          .map((m) => Membership.fromJson(m))
          .toList(),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
