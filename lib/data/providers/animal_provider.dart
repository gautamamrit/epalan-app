import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
import 'farm_provider.dart';

/// Animal service provider
final animalServiceProvider = Provider<AnimalService>((ref) => AnimalService());

/// Animals list state
class AnimalsState {
  final List<Animal> animals;
  final bool isLoading;
  final String? error;
  final String? filterStatus;

  AnimalsState({
    this.animals = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });

  AnimalsState copyWith({
    List<Animal>? animals,
    bool? isLoading,
    String? error,
    String? filterStatus,
  }) {
    return AnimalsState(
      animals: animals ?? this.animals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  List<Animal> get activeAnimals =>
      animals.where((a) => a.status == 'active').toList();

  List<Animal> get pastAnimals =>
      animals.where((a) => a.status != 'active').toList();
}

/// Animals notifier
class AnimalsNotifier extends StateNotifier<AnimalsState> {
  final AnimalService _animalService;
  final Ref _ref;

  AnimalsNotifier(this._animalService, this._ref) : super(AnimalsState());

  String? get _farmId => _ref.read(selectedFarmProvider)?.id;

  Future<void> loadAnimals({String? status, String? farmId}) async {
    final id = farmId ?? _farmId;
    if (id == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null, filterStatus: status);
    try {
      final animals = await _animalService.getAnimals(id, status: status);
      state = state.copyWith(
        animals: animals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Animal?> createAnimal({
    required String categoryId,
    String? breedId,
    String? name,
    required DateTime startDate,
    int? initialQuantity,
    String? tagNumber,
    String? sex,
    DateTime? dateOfBirth,
    String? shortCode,
    String? sourceType,
    String? sourceNotes,
  }) async {
    if (_farmId == null) return null;

    try {
      final animal = await _animalService.createAnimal(
        _farmId!,
        categoryId: categoryId,
        breedId: breedId,
        name: name,
        startDate: startDate,
        initialQuantity: initialQuantity,
        tagNumber: tagNumber,
        sex: sex,
        dateOfBirth: dateOfBirth,
        shortCode: shortCode,
        sourceType: sourceType,
        sourceNotes: sourceNotes,
      );
      state = state.copyWith(animals: [animal, ...state.animals]);
      return animal;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> updateAnimal(
    String animalId, {
    String? name,
    String? breedId,
    int? initialQuantity,
    String? sourceNotes,
  }) async {
    if (_farmId == null) return false;

    try {
      final updatedAnimal = await _animalService.updateAnimal(
        _farmId!,
        animalId,
        name: name,
        breedId: breedId,
        initialQuantity: initialQuantity,
        sourceNotes: sourceNotes,
      );
      state = state.copyWith(
        animals: state.animals.map((a) => a.id == animalId ? updatedAnimal : a).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Animals provider (depends on selected farm)
final animalsProvider = StateNotifierProvider<AnimalsNotifier, AnimalsState>((ref) {
  final animalService = ref.watch(animalServiceProvider);
  return AnimalsNotifier(animalService, ref);
});

/// Active animals count
final activeAnimalsCountProvider = Provider<int>((ref) {
  return ref.watch(animalsProvider).activeAnimals.length;
});

/// Total livestock count
final totalLivestockCountProvider = Provider<int>((ref) {
  final animals = ref.watch(animalsProvider).activeAnimals;
  return animals.fold(0, (sum, animal) => sum + animal.headCount);
});

/// Animal detail state
class AnimalDetailState {
  final AnimalDetail? detail;
  final bool isLoading;
  final String? error;

  AnimalDetailState({
    this.detail,
    this.isLoading = false,
    this.error,
  });

  AnimalDetailState copyWith({
    AnimalDetail? detail,
    bool? isLoading,
    String? error,
  }) {
    return AnimalDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Animal detail notifier
class AnimalDetailNotifier extends StateNotifier<AnimalDetailState> {
  final AnimalService _animalService;

  AnimalDetailNotifier(this._animalService) : super(AnimalDetailState());

  Future<void> loadAnimalDetail(String farmId, String animalId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final detail = await _animalService.getAnimalDetail(farmId, animalId);
      state = AnimalDetailState(detail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = AnimalDetailState();
  }
}

/// Animal detail provider
final animalDetailProvider = StateNotifierProvider<AnimalDetailNotifier, AnimalDetailState>((ref) {
  final animalService = ref.watch(animalServiceProvider);
  return AnimalDetailNotifier(animalService);
});

/// Vaccinations provider
final vaccinationsProvider = FutureProvider.family<List<Vaccination>, String>((ref, animalId) async {
  final animalService = ref.watch(animalServiceProvider);
  final selectedFarm = ref.watch(selectedFarmProvider);

  if (selectedFarm == null) return [];

  try {
    return await animalService.getVaccinations(selectedFarm.id, animalId);
  } catch (e) {
    return [];
  }
});

/// Medications provider
final medicationsProvider = FutureProvider.family<List<Medication>, String>((ref, animalId) async {
  final animalService = ref.watch(animalServiceProvider);
  final selectedFarm = ref.watch(selectedFarmProvider);

  if (selectedFarm == null) return [];

  try {
    return await animalService.getMedications(selectedFarm.id, animalId);
  } catch (e) {
    return [];
  }
});

/// Daily records provider
final dailyRecordsProvider = FutureProvider.family<List<DailyRecord>, String>((ref, animalId) async {
  final animalService = ref.watch(animalServiceProvider);
  final selectedFarm = ref.watch(selectedFarmProvider);

  if (selectedFarm == null) return [];

  try {
    return await animalService.getDailyRecords(selectedFarm.id, animalId);
  } catch (e) {
    return [];
  }
});

// ============================================================================
// ALERTS
// ============================================================================

/// Alert item model (wrapper for vaccination or medication with animal info)
class AlertItem {
  final String id;
  final String animalId;
  final String animalName;
  final String categoryName;
  final String name;
  final String type; // 'vaccination' or 'medication'
  final int fromDay;
  final int toDay;
  final DateTime? dueFromDate;
  final DateTime? dueToDate;
  final String status;
  final String? route; // for vaccination
  final String? dosage; // for medication
  final String? notes;

  AlertItem({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.categoryName,
    required this.name,
    required this.type,
    required this.fromDay,
    required this.toDay,
    this.dueFromDate,
    this.dueToDate,
    required this.status,
    this.route,
    this.dosage,
    this.notes,
  });

  bool get isVaccination => type == 'vaccination';
  bool get isMedication => type == 'medication';
  bool get isPending => status == 'pending';

  bool get isOverdue {
    if (status != 'pending' || dueToDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueTo = DateTime(dueToDate!.year, dueToDate!.month, dueToDate!.day);
    return today.isAfter(dueTo);
  }

  bool get isDueToday {
    if (status != 'pending' || dueFromDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueFrom = DateTime(dueFromDate!.year, dueFromDate!.month, dueFromDate!.day);
    final dueTo = dueToDate != null
        ? DateTime(dueToDate!.year, dueToDate!.month, dueToDate!.day)
        : dueFrom;
    return !today.isAfter(dueTo) &&
           (today.isAtSameMomentAs(dueFrom) || today.isAfter(dueFrom));
  }

  bool get isUpcoming {
    if (dueFromDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueFrom = DateTime(dueFromDate!.year, dueFromDate!.month, dueFromDate!.day);
    return dueFrom.isAfter(today);
  }

  int get daysUntilDue {
    if (dueFromDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueFrom = DateTime(dueFromDate!.year, dueFromDate!.month, dueFromDate!.day);
    return dueFrom.difference(today).inDays;
  }
}

/// Alerts state
class AlertsState {
  final List<AlertItem> alerts;
  final bool isLoading;
  final String? error;

  AlertsState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
  });

  AlertsState copyWith({
    List<AlertItem>? alerts,
    bool? isLoading,
    String? error,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<AlertItem> get dueToday => alerts.where((a) => a.isDueToday || a.isOverdue).toList();
  List<AlertItem> get upcoming => alerts.where((a) => a.isUpcoming).toList();
}

/// Alerts notifier
class AlertsNotifier extends StateNotifier<AlertsState> {
  final AnimalService _animalService;
  final Ref _ref;

  AlertsNotifier(this._animalService, this._ref) : super(AlertsState());

  String? get _farmId => _ref.read(selectedFarmProvider)?.id;

  Future<void> loadAlerts() async {
    if (_farmId == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Single API call — no N+1
      final alerts = await _animalService.getFarmAlerts(_farmId!);
      final List<AlertItem> allAlerts = [];

      for (final v in alerts.vaccinations) {
        allAlerts.add(AlertItem(
          id: v.id,
          animalId: v.animalId,
          animalName: v.animalName ?? 'Unknown',
          categoryName: '',
          name: v.name,
          type: 'vaccination',
          fromDay: v.fromDay,
          toDay: v.toDay,
          dueFromDate: v.dueFromDate,
          dueToDate: v.dueToDate,
          status: v.status,
          route: v.route,
          notes: v.notes,
        ));
      }

      for (final m in alerts.medications) {
        allAlerts.add(AlertItem(
          id: m.id,
          animalId: m.animalId,
          animalName: m.animalName ?? 'Unknown',
          categoryName: '',
          name: m.name,
          type: 'medication',
          fromDay: m.fromDay,
          toDay: m.toDay,
          dueFromDate: m.dueFromDate,
          dueToDate: m.dueToDate,
          status: m.status,
          dosage: m.dosage,
          notes: m.notes,
        ));
      }

      allAlerts.sort((a, b) {
        if (a.dueFromDate == null && b.dueFromDate == null) return 0;
        if (a.dueFromDate == null) return 1;
        if (b.dueFromDate == null) return -1;
        return a.dueFromDate!.compareTo(b.dueFromDate!);
      });

      state = state.copyWith(alerts: allAlerts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> completeVaccination(String animalId, String vaccinationId) async {
    if (_farmId == null) return false;

    try {
      await _animalService.completeVaccination(_farmId!, animalId, vaccinationId);
      // Remove from alerts list
      state = state.copyWith(
        alerts: state.alerts.where((a) => a.id != vaccinationId).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeMedication(String animalId, String medicationId) async {
    if (_farmId == null) return false;

    try {
      await _animalService.completeMedication(_farmId!, animalId, medicationId);
      // Remove from alerts list
      state = state.copyWith(
        alerts: state.alerts.where((a) => a.id != medicationId).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Alerts provider
final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  final animalService = ref.watch(animalServiceProvider);
  return AlertsNotifier(animalService, ref);
});

/// Alerts count (due today + overdue)
final alertsCountProvider = Provider<int>((ref) {
  return ref.watch(alertsProvider).dueToday.length;
});
