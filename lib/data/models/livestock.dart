/// Livestock category model
class LivestockCategory {
  final String id;
  final String name;
  final String? nameNe;
  final String subtypeId;
  final String managedAs; // 'individual' | 'group'
  final bool isActive;
  final LivestockSubtype? subtype;

  LivestockCategory({
    required this.id,
    required this.name,
    this.nameNe,
    required this.subtypeId,
    this.managedAs = 'group',
    required this.isActive,
    this.subtype,
  });

  bool get isIndividual => managedAs == 'individual';
  bool get isGroup => managedAs == 'group';

  factory LivestockCategory.fromJson(Map<String, dynamic> json) {
    return LivestockCategory(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      subtypeId: json['subtypeId'],
      managedAs: json['managedAs'] ?? 'group',
      isActive: json['isActive'] ?? true,
      subtype: json['subtype'] != null
          ? LivestockSubtype.fromJson(json['subtype'])
          : null,
    );
  }
}

/// Livestock subtype model
class LivestockSubtype {
  final String id;
  final String name;
  final String? nameNe;
  final String typeId;
  final bool isActive;
  final LivestockType? type;

  LivestockSubtype({
    required this.id,
    required this.name,
    this.nameNe,
    required this.typeId,
    required this.isActive,
    this.type,
  });

  factory LivestockSubtype.fromJson(Map<String, dynamic> json) {
    return LivestockSubtype(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      typeId: json['typeId'],
      isActive: json['isActive'] ?? true,
      type: json['type'] != null ? LivestockType.fromJson(json['type']) : null,
    );
  }
}

/// Livestock type model
class LivestockType {
  final String id;
  final String name;
  final String? nameNe;
  final bool isActive;

  LivestockType({
    required this.id,
    required this.name,
    this.nameNe,
    required this.isActive,
  });

  factory LivestockType.fromJson(Map<String, dynamic> json) {
    return LivestockType(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      isActive: json['isActive'] ?? true,
    );
  }
}

/// Livestock breed model
class LivestockBreed {
  final String id;
  final String name;
  final String? nameNe;
  final String categoryId;
  final bool isActive;
  final LivestockCategory? category;

  LivestockBreed({
    required this.id,
    required this.name,
    this.nameNe,
    required this.categoryId,
    required this.isActive,
    this.category,
  });

  factory LivestockBreed.fromJson(Map<String, dynamic> json) {
    return LivestockBreed(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      categoryId: json['categoryId'],
      isActive: json['isActive'] ?? true,
      category: json['category'] != null
          ? LivestockCategory.fromJson(json['category'])
          : null,
    );
  }
}
