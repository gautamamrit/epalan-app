import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/livestock.dart';
import '../services/livestock_service.dart';

/// Livestock service provider
final livestockServiceProvider = Provider<LivestockService>((ref) => LivestockService());

/// Categories state
class CategoriesState {
  final List<LivestockCategory> categories;
  final bool isLoading;
  final String? error;

  CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesState copyWith({
    List<LivestockCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Categories notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final LivestockService _livestockService;

  CategoriesNotifier(this._livestockService) : super(CategoriesState());

  Future<void> loadCategories() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _livestockService.getCategories();
      state = CategoriesState(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Categories provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final livestockService = ref.watch(livestockServiceProvider);
  return CategoriesNotifier(livestockService);
});

/// Breeds state (dependent on selected category)
class BreedsState {
  final List<LivestockBreed> breeds;
  final bool isLoading;
  final String? error;

  BreedsState({
    this.breeds = const [],
    this.isLoading = false,
    this.error,
  });

  BreedsState copyWith({
    List<LivestockBreed>? breeds,
    bool? isLoading,
    String? error,
  }) {
    return BreedsState(
      breeds: breeds ?? this.breeds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Breeds notifier
class BreedsNotifier extends StateNotifier<BreedsState> {
  final LivestockService _livestockService;

  BreedsNotifier(this._livestockService) : super(BreedsState());

  Future<void> loadBreeds(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final breeds = await _livestockService.getBreeds(categoryId: categoryId);
      state = BreedsState(breeds: breeds, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = BreedsState();
  }
}

/// Breeds provider
final breedsProvider = StateNotifierProvider<BreedsNotifier, BreedsState>((ref) {
  final livestockService = ref.watch(livestockServiceProvider);
  return BreedsNotifier(livestockService);
});

/// Livestock types provider (for farm creation)
final livestockTypesProvider = FutureProvider<List<LivestockType>>((ref) async {
  final service = ref.watch(livestockServiceProvider);
  return service.getTypes();
});
