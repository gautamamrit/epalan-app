import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farm.dart';
import '../services/farm_service.dart';

/// Farm service provider
final farmServiceProvider = Provider<FarmService>((ref) => FarmService());

/// Farms list state
class FarmsState {
  final List<Farm> farms;
  final List<Farm> deletedFarms;
  final bool isLoading;
  final String? error;
  final int total;

  FarmsState({
    this.farms = const [],
    this.deletedFarms = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
  });

  FarmsState copyWith({
    List<Farm>? farms,
    List<Farm>? deletedFarms,
    bool? isLoading,
    String? error,
    int? total,
  }) {
    return FarmsState(
      farms: farms ?? this.farms,
      deletedFarms: deletedFarms ?? this.deletedFarms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
    );
  }
}

/// Farms notifier
class FarmsNotifier extends StateNotifier<FarmsState> {
  final FarmService _farmService;

  FarmsNotifier(this._farmService) : super(FarmsState());

  /// Single call — fetches active + deleted farms together
  Future<void> loadFarms({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _farmService.getFarms(includeDeleted: true);
      final active = response.farms.where((f) => f.deletedAt == null).toList();
      final deleted = response.farms.where((f) => f.deletedAt != null).toList();
      state = FarmsState(
        farms: active,
        deletedFarms: deleted,
        total: active.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Farm?> createFarm({
    required String name,
    required int countryId,
    required int provinceId,
    required int districtId,
    String? address,
    required List<Map<String, dynamic>> livestockTypes,
  }) async {
    try {
      final farm = await _farmService.createFarm(
        name: name,
        countryId: countryId,
        provinceId: provinceId,
        districtId: districtId,
        address: address,
        livestockTypes: livestockTypes,
      );
      state = state.copyWith(
        farms: [farm, ...state.farms],
        total: state.total + 1,
      );
      return farm;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> updateFarm(
    String farmId, {
    String? name,
    int? countryId,
    int? provinceId,
    int? districtId,
    String? address,
    bool? isActive,
  }) async {
    try {
      final updatedFarm = await _farmService.updateFarm(
        farmId,
        name: name,
        countryId: countryId,
        provinceId: provinceId,
        districtId: districtId,
        address: address,
        isActive: isActive,
      );
      state = state.copyWith(
        farms: state.farms.map((f) => f.id == farmId ? updatedFarm : f).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addLivestockTypes(
      String farmId, List<String> livestockTypeIds) async {
    try {
      final updatedFarm =
          await _farmService.addLivestockTypes(farmId, livestockTypeIds);
      state = state.copyWith(
        farms: state.farms.map((f) => f.id == farmId ? updatedFarm : f).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> removeLivestockType(String farmId, String typeId) async {
    try {
      final updatedFarm =
          await _farmService.removeLivestockType(farmId, typeId);
      state = state.copyWith(
        farms: state.farms.map((f) => f.id == farmId ? updatedFarm : f).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteFarm(String farmId) async {
    try {
      final farm = state.farms.firstWhere((f) => f.id == farmId);
      await _farmService.deleteFarm(farmId);
      state = state.copyWith(
        farms: state.farms.where((f) => f.id != farmId).toList(),
        deletedFarms: [farm, ...state.deletedFarms],
        total: state.total - 1,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Farms provider
final farmsProvider = StateNotifierProvider<FarmsNotifier, FarmsState>((ref) {
  final farmService = ref.watch(farmServiceProvider);
  return FarmsNotifier(farmService);
});

/// Selected farm provider
final selectedFarmIdProvider = StateProvider<String?>((ref) => null);

/// Selected farm — always returns the first active farm if none explicitly selected
final selectedFarmProvider = Provider<Farm?>((ref) {
  final selectedId = ref.watch(selectedFarmIdProvider);
  final farms = ref.watch(farmsProvider).farms;
  if (farms.isEmpty) return null;
  if (selectedId == null) return farms.first;
  return farms.firstWhere((f) => f.id == selectedId, orElse: () => farms.first);
});
