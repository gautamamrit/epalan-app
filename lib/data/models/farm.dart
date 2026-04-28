/// Farm model
class Farm {
  final String id;
  final String name;
  final String ownerId;
  final int countryId;
  final int provinceId;
  final int districtId;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final FarmOwner? owner;
  final Location? country;
  final Location? province;
  final Location? district;
  final List<FarmLivestockType>? livestockTypes;
  final FarmSubscription? subscription;

  Farm({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.countryId,
    required this.provinceId,
    required this.districtId,
    this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.owner,
    this.country,
    this.province,
    this.district,
    this.livestockTypes,
    this.subscription,
  });

  String get locationString {
    final parts = <String>[];
    if (district != null) parts.add(district!.name);
    if (province != null) parts.add(province!.name);
    return parts.join(', ');
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      name: json['name'],
      ownerId: json['ownerId'],
      countryId: json['countryId'],
      provinceId: json['provinceId'],
      districtId: json['districtId'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      owner: json['owner'] != null ? FarmOwner.fromJson(json['owner']) : null,
      country: json['country'] != null ? Location.fromJson(json['country']) : null,
      province: json['province'] != null ? Location.fromJson(json['province']) : null,
      district: json['district'] != null ? Location.fromJson(json['district']) : null,
      livestockTypes: json['livestockTypes'] != null
          ? (json['livestockTypes'] as List)
              .map((lt) => FarmLivestockType.fromJson(lt))
              .toList()
          : null,
      subscription: json['subscription'] != null
          ? FarmSubscription.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'countryId': countryId,
      'provinceId': provinceId,
      'districtId': districtId,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FarmOwner {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;

  FarmOwner({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
  });

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  factory FarmOwner.fromJson(Map<String, dynamic> json) {
    return FarmOwner(
      id: json['id'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
    );
  }
}

class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
    );
  }
}

class FarmLivestockType {
  final String id;
  final String farmId;
  final String livestockTypeId;
  final int? capacity;
  final LivestockTypeDetail? livestockType;

  FarmLivestockType({
    required this.id,
    required this.farmId,
    required this.livestockTypeId,
    this.capacity,
    this.livestockType,
  });

  factory FarmLivestockType.fromJson(Map<String, dynamic> json) {
    return FarmLivestockType(
      id: json['id'],
      farmId: json['farmId'],
      livestockTypeId: json['livestockTypeId'],
      capacity: json['capacity'],
      livestockType: json['livestockType'] != null
          ? LivestockTypeDetail.fromJson(json['livestockType'])
          : null,
    );
  }
}

class LivestockTypeDetail {
  final String id;
  final String name;
  final String? nameNe;
  final String? description;
  final String? icon;

  LivestockTypeDetail({
    required this.id,
    required this.name,
    this.nameNe,
    this.description,
    this.icon,
  });

  factory LivestockTypeDetail.fromJson(Map<String, dynamic> json) {
    return LivestockTypeDetail(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class FarmSubscription {
  final String id;
  final String status;
  final String? planId;
  final String? planName;
  final String? billingCycle;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialEndAt;

  FarmSubscription({
    required this.id,
    required this.status,
    this.planId,
    this.planName,
    this.billingCycle,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialEndAt,
  });

  bool get isActive => status == 'active' || status == 'trial';

  factory FarmSubscription.fromJson(Map<String, dynamic> json) {
    return FarmSubscription(
      id: json['id'],
      status: json['status'],
      planId: json['planId'],
      planName: json['planName'],
      billingCycle: json['billingCycle'],
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.parse(json['currentPeriodStart'])
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.parse(json['currentPeriodEnd'])
          : null,
      trialEndAt: json['trialEndAt'] != null
          ? DateTime.parse(json['trialEndAt'])
          : null,
    );
  }
}

/// Farms list response
class FarmsResponse {
  final List<Farm> farms;
  final int total;
  final int limit;
  final int offset;

  FarmsResponse({
    required this.farms,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory FarmsResponse.fromJson(Map<String, dynamic> json) {
    return FarmsResponse(
      farms: (json['farms'] as List).map((f) => Farm.fromJson(f)).toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}
