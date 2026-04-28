/// Animal model
class Animal {
  final String id;
  final String farmId;
  final String categoryId;
  final String? breedId;
  final String? name;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  // Group-only
  final int? initialQuantity;
  final int? currentQuantity;
  // Individual-only
  final String? tagNumber;
  final String? sex;
  final DateTime? dateOfBirth;
  final String? damId;
  final String? sireId;
  final String? animalGroupId;
  final String? profilePhotoUrl;
  final String? shortCode;
  // Source
  final String? sourceType;
  final String? sourceOrderId;
  final String? sourceNotes;
  final String? endNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnimalCategory? category;
  final AnimalBreed? breed;

  Animal({
    required this.id,
    required this.farmId,
    required this.categoryId,
    this.breedId,
    this.name,
    required this.status,
    required this.startDate,
    this.endDate,
    this.initialQuantity,
    this.currentQuantity,
    this.tagNumber,
    this.sex,
    this.dateOfBirth,
    this.damId,
    this.sireId,
    this.animalGroupId,
    this.profilePhotoUrl,
    this.shortCode,
    this.sourceType,
    this.sourceOrderId,
    this.sourceNotes,
    this.endNotes,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.breed,
  });

  /// Whether this is an individually-tracked animal (from category.managedAs)
  bool get isIndividual => category?.managedAs == 'individual';

  /// Days since animal tracking started
  int get daysElapsed {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays + 1;
  }

  /// Display name (generated if not set)
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    return 'Animal-${id.substring(0, 8).toUpperCase()}';
  }

  /// Current head count (fallback to initial, 1 for individual)
  int get headCount => currentQuantity ?? initialQuantity ?? 1;

  /// Is animal active
  bool get isActive => status == 'active';

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      farmId: json['farmId'],
      categoryId: json['categoryId'],
      breedId: json['breedId'],
      name: json['name'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      initialQuantity: json['initialQuantity'],
      currentQuantity: json['currentQuantity'],
      tagNumber: json['tagNumber'],
      sex: json['sex'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      damId: json['damId'],
      sireId: json['sireId'],
      animalGroupId: json['animalGroupId'],
      profilePhotoUrl: json['profilePhotoUrl'],
      shortCode: json['shortCode'],
      sourceType: json['sourceType'],
      sourceOrderId: json['sourceOrderId'],
      sourceNotes: json['sourceNotes'],
      endNotes: json['endNotes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt']),
      category: json['category'] != null
          ? AnimalCategory.fromJson(json['category'])
          : null,
      breed: json['breed'] != null ? AnimalBreed.fromJson(json['breed']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'categoryId': categoryId,
      'breedId': breedId,
      'name': name,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'initialQuantity': initialQuantity,
      'currentQuantity': currentQuantity,
    };
  }
}

class AnimalCategory {
  final String id;
  final String name;
  final String? nameNe;
  final String subtypeId;
  final String managedAs;
  final AnimalSubtype? subtype;

  AnimalCategory({
    required this.id,
    required this.name,
    this.nameNe,
    required this.subtypeId,
    this.managedAs = 'group',
    this.subtype,
  });

  bool get isIndividual => managedAs == 'individual';
  bool get isGroup => managedAs == 'group';

  factory AnimalCategory.fromJson(Map<String, dynamic> json) {
    return AnimalCategory(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      subtypeId: json['subtypeId'],
      managedAs: json['managedAs'] ?? 'group',
      subtype:
          json['subtype'] != null ? AnimalSubtype.fromJson(json['subtype']) : null,
    );
  }
}

class AnimalSubtype {
  final String id;
  final String name;
  final String? nameNe;
  final String typeId;

  AnimalSubtype({
    required this.id,
    required this.name,
    this.nameNe,
    required this.typeId,
  });

  factory AnimalSubtype.fromJson(Map<String, dynamic> json) {
    return AnimalSubtype(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
      typeId: json['typeId'],
    );
  }
}

class AnimalBreed {
  final String id;
  final String name;
  final String? nameNe;

  AnimalBreed({
    required this.id,
    required this.name,
    this.nameNe,
  });

  factory AnimalBreed.fromJson(Map<String, dynamic> json) {
    return AnimalBreed(
      id: json['id'],
      name: json['name'],
      nameNe: json['nameNe'],
    );
  }
}

/// Animal stats
class AnimalStats {
  final int daysElapsed;
  final int initialQuantity;
  final int? currentQuantity;
  final int totalMortality;
  final double mortalityRate;
  final double totalFeedKg;
  final int totalEggs;
  final double? latestAvgWeightKg;
  final double? fcr;

  AnimalStats({
    required this.daysElapsed,
    required this.initialQuantity,
    this.currentQuantity,
    required this.totalMortality,
    required this.mortalityRate,
    required this.totalFeedKg,
    required this.totalEggs,
    this.latestAvgWeightKg,
    this.fcr,
  });

  factory AnimalStats.fromJson(Map<String, dynamic> json) {
    return AnimalStats(
      daysElapsed: _parseInt(json['daysElapsed']) ?? 0,
      initialQuantity: _parseInt(json['initialQuantity']) ?? 0,
      currentQuantity: _parseInt(json['currentQuantity']),
      totalMortality: _parseInt(json['totalMortality']) ?? 0,
      mortalityRate: _parseDouble(json['mortalityRate']) ?? 0.0,
      totalFeedKg: _parseDouble(json['totalFeedKg']) ?? 0.0,
      totalEggs: _parseInt(json['totalEggs']) ?? 0,
      latestAvgWeightKg: _parseDouble(json['latestAvgWeightKg']),
      fcr: _parseDouble(json['fcr']),
    );
  }
}

/// Safe parsing helpers for JSON values that might be String or num
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Health summary
class HealthSummary {
  final HealthCount vaccinations;
  final HealthCount medications;

  HealthSummary({
    required this.vaccinations,
    required this.medications,
  });

  factory HealthSummary.fromJson(Map<String, dynamic> json) {
    return HealthSummary(
      vaccinations: HealthCount.fromJson(json['vaccinations']),
      medications: HealthCount.fromJson(json['medications']),
    );
  }
}

class HealthCount {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  HealthCount({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  factory HealthCount.fromJson(Map<String, dynamic> json) {
    return HealthCount(
      total: json['total'],
      completed: json['completed'],
      pending: json['pending'],
      overdue: json['overdue'],
    );
  }
}

/// Animal detail response
class AnimalDetail {
  final Animal animal;
  final AnimalStats stats;
  final HealthSummary healthSummary;
  final List<DailyRecord> recentRecords;
  final UpcomingHealth upcomingHealth;

  AnimalDetail({
    required this.animal,
    required this.stats,
    required this.healthSummary,
    required this.recentRecords,
    required this.upcomingHealth,
  });

  factory AnimalDetail.fromJson(Map<String, dynamic> json) {
    return AnimalDetail(
      animal: Animal.fromJson(json['animal']),
      stats: AnimalStats.fromJson(json['stats']),
      healthSummary: HealthSummary.fromJson(json['healthSummary']),
      recentRecords: (json['recentRecords'] as List)
          .map((r) => DailyRecord.fromJson(r))
          .toList(),
      upcomingHealth: UpcomingHealth.fromJson(json['upcomingHealth']),
    );
  }
}

class UpcomingHealth {
  final List<Vaccination> vaccinations;
  final List<Medication> medications;

  UpcomingHealth({
    required this.vaccinations,
    required this.medications,
  });

  factory UpcomingHealth.fromJson(Map<String, dynamic> json) {
    return UpcomingHealth(
      vaccinations: (json['vaccinations'] as List)
          .map((v) => Vaccination.fromJson(v))
          .toList(),
      medications: (json['medications'] as List)
          .map((m) => Medication.fromJson(m))
          .toList(),
    );
  }
}

/// Daily record
class DailyRecord {
  final String id;
  final String animalId;
  final DateTime recordDate;
  final int? dayNumber;
  final int mortalityCount;
  final String? mortalityReason;
  final double? feedConsumedKg;
  final int? sampleCount;
  final double? avgWeightKg;
  final int? eggsCollected;
  final String? notes;
  final DateTime createdAt;

  DailyRecord({
    required this.id,
    required this.animalId,
    required this.recordDate,
    this.dayNumber,
    required this.mortalityCount,
    this.mortalityReason,
    this.feedConsumedKg,
    this.sampleCount,
    this.avgWeightKg,
    this.eggsCollected,
    this.notes,
    required this.createdAt,
  });

  // Compatibility getters
  String? get mortalityNotes => mortalityReason;
  int? get weightSampleSize => sampleCount;
  double? get weightAvgKg => avgWeightKg;

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      id: json['id'],
      animalId: json['animalId'] ?? json['batchId'],
      recordDate: DateTime.parse(json['recordDate']),
      dayNumber: _parseInt(json['dayNumber']),
      mortalityCount: _parseInt(json['mortalityCount']) ?? 0,
      mortalityReason: json['mortalityReason'],
      feedConsumedKg: _parseDouble(json['feedConsumedKg']),
      sampleCount: _parseInt(json['sampleCount']),
      avgWeightKg: _parseDouble(json['avgWeightKg']),
      eggsCollected: _parseInt(json['eggsCollected']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Vaccination
class Vaccination {
  final String id;
  final String animalId;
  final String? animalName;
  final String? scheduleItemId;
  final String name;
  final int fromDay;
  final int toDay;
  final DateTime? dueFromDate;
  final DateTime? dueToDate;
  final String? route;
  final String status;
  final DateTime? completedAt;
  final String? administeredByName;
  final String? recordedByName;
  final String? notes;

  Vaccination({
    required this.id,
    required this.animalId,
    this.animalName,
    this.scheduleItemId,
    required this.name,
    required this.fromDay,
    required this.toDay,
    this.dueFromDate,
    this.dueToDate,
    this.route,
    required this.status,
    this.completedAt,
    this.administeredByName,
    this.recordedByName,
    this.notes,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  // For display
  int get scheduledDay => fromDay;
  String? get method => route;

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      animalId: json['animalId'] ?? json['batchId'],
      animalName: json['animal']?['name'],
      scheduleItemId: json['scheduleItemId'],
      name: json['vaccineName'] ?? json['name'] ?? 'Unknown',
      fromDay: json['fromDay'] ?? json['scheduledDay'] ?? 0,
      toDay: json['toDay'] ?? json['fromDay'] ?? 0,
      dueFromDate: json['dueFromDate'] != null
          ? DateTime.parse(json['dueFromDate'])
          : null,
      dueToDate: json['dueToDate'] != null
          ? DateTime.parse(json['dueToDate'])
          : null,
      route: json['route'],
      status: json['status'] ?? 'pending',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      administeredByName: _formatUserName(json['administrator']),
      recordedByName: _formatUserName(json['recorder']),
      notes: json['notes'],
    );
  }
}

String? _formatUserName(Map<String, dynamic>? user) {
  if (user == null) return null;
  final first = user['firstName'] ?? '';
  final last = user['lastName'] ?? '';
  return '$first $last'.trim();
}

/// Medication
class Medication {
  final String id;
  final String animalId;
  final String? animalName;
  final String? scheduleItemId;
  final String name;
  final int fromDay;
  final int toDay;
  final DateTime? dueFromDate;
  final DateTime? dueToDate;
  final String? purpose;
  final String? dosage;
  final String status;
  final DateTime? completedAt;
  final String? administeredByName;
  final String? recordedByName;
  final String? notes;

  Medication({
    required this.id,
    required this.animalId,
    this.animalName,
    this.scheduleItemId,
    required this.name,
    required this.fromDay,
    required this.toDay,
    this.dueFromDate,
    this.dueToDate,
    this.purpose,
    this.dosage,
    required this.status,
    this.completedAt,
    this.administeredByName,
    this.recordedByName,
    this.notes,
  });

  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';

  // For display compatibility
  int get scheduledStartDay => fromDay;
  int get scheduledEndDay => toDay;
  String? get method => purpose;
  int get durationDays => toDay - fromDay + 1;

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      animalId: json['animalId'] ?? json['batchId'],
      animalName: json['animal']?['name'],
      scheduleItemId: json['scheduleItemId'],
      name: json['medicationName'] ?? json['name'] ?? 'Unknown',
      fromDay: json['fromDay'] ?? json['scheduledStartDay'] ?? 0,
      toDay: json['toDay'] ?? json['scheduledEndDay'] ?? 0,
      dueFromDate: json['dueFromDate'] != null
          ? DateTime.parse(json['dueFromDate'])
          : null,
      dueToDate: json['dueToDate'] != null
          ? DateTime.parse(json['dueToDate'])
          : null,
      purpose: json['purpose'],
      dosage: json['dosage'],
      status: json['status'] ?? 'pending',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      administeredByName: _formatUserName(json['administrator']),
      recordedByName: _formatUserName(json['recorder']),
      notes: json['notes'],
    );
  }
}

/// Health Program (vaccination or medication)
class HealthProgram {
  final String id;
  final String name;
  final String? description;

  HealthProgram({
    required this.id,
    required this.name,
    this.description,
  });

  factory HealthProgram.fromJson(Map<String, dynamic> json) {
    return HealthProgram(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      description: json['description'],
    );
  }
}

/// Health Program with schedule items
class HealthProgramDetail {
  final String id;
  final String name;
  final String? description;
  final List<ScheduleItem> scheduleItems;

  HealthProgramDetail({
    required this.id,
    required this.name,
    this.description,
    required this.scheduleItems,
  });

  factory HealthProgramDetail.fromJson(Map<String, dynamic> json) {
    return HealthProgramDetail(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      description: json['description'],
      scheduleItems: (json['scheduleItems'] as List? ?? [])
          .map((i) => ScheduleItem.fromJson(i))
          .toList(),
    );
  }
}

/// Schedule item within a health program
class ScheduleItem {
  final String id;
  final int fromDay;
  final int toDay;
  final String name;
  final String? route;
  final String? dosage;
  final String? notes;

  ScheduleItem({
    required this.id,
    required this.fromDay,
    required this.toDay,
    required this.name,
    this.route,
    this.dosage,
    this.notes,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      fromDay: json['fromDay'] ?? 0,
      toDay: json['toDay'] ?? 0,
      name: json['vaccineName'] ?? json['medicationName'] ?? json['name'] ?? 'Unknown',
      route: json['route'],
      dosage: json['dosage'],
      notes: json['notes'],
    );
  }
}
