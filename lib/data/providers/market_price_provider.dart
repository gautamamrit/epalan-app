import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_price.dart';
import '../services/market_price_service.dart';

final marketPriceServiceProvider = Provider<MarketPriceService>((ref) => MarketPriceService());

class MarketPriceState {
  final List<MarketPriceItem> items;
  final List<MarketPrice> latestPrices;
  final List<MarketPrice> historicalPrices;
  final bool isLoading;
  final String? error;
  final int? selectedProvinceId;
  final Set<String> selectedItemIds;
  final int selectedDays;

  MarketPriceState({
    this.items = const [],
    this.latestPrices = const [],
    this.historicalPrices = const [],
    this.isLoading = false,
    this.error,
    this.selectedProvinceId,
    this.selectedItemIds = const {},
    this.selectedDays = 7,
  });

  MarketPriceState copyWith({
    List<MarketPriceItem>? items,
    List<MarketPrice>? latestPrices,
    List<MarketPrice>? historicalPrices,
    bool? isLoading,
    String? error,
    int? selectedProvinceId,
    Set<String>? selectedItemIds,
    int? selectedDays,
  }) {
    return MarketPriceState(
      items: items ?? this.items,
      latestPrices: latestPrices ?? this.latestPrices,
      historicalPrices: historicalPrices ?? this.historicalPrices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedProvinceId: selectedProvinceId ?? this.selectedProvinceId,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  MarketPrice? latestForItem(String itemId) {
    return latestPrices
        .where((p) => p.itemId == itemId)
        .where((p) => selectedProvinceId == null || p.provinceId == selectedProvinceId)
        .fold<MarketPrice?>(null, (prev, p) => prev == null || p.date.compareTo(prev.date) > 0 ? p : prev);
  }

  List<MarketPrice> historyForItem(String itemId) {
    return historicalPrices
        .where((p) => p.itemId == itemId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

class MarketPriceNotifier extends StateNotifier<MarketPriceState> {
  final MarketPriceService _service;

  MarketPriceNotifier(this._service) : super(MarketPriceState());

  Future<void> load({int? provinceId}) async {
    state = state.copyWith(isLoading: true, error: null, selectedProvinceId: provinceId);
    try {
      final dateFrom = _daysAgo(state.selectedDays);
      final results = await Future.wait([
        _service.getItems(),
        _service.getLatestPrices(provinceId: provinceId),
        _service.getMarketPrices(provinceId: provinceId, dateFrom: dateFrom),
      ]);
      state = state.copyWith(
        items: results[0] as List<MarketPriceItem>,
        latestPrices: results[1] as List<MarketPrice>,
        historicalPrices: results[2] as List<MarketPrice>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleItem(String itemId) {
    final ids = Set<String>.from(state.selectedItemIds);
    if (ids.contains(itemId)) {
      ids.remove(itemId);
    } else {
      ids.add(itemId);
    }
    state = state.copyWith(selectedItemIds: ids);
  }

  void clearItemFilter() {
    state = state.copyWith(selectedItemIds: {});
  }

  Future<void> changeDays(int days) async {
    state = state.copyWith(selectedDays: days);
    final dateFrom = _daysAgo(days);
    try {
      final history = await _service.getMarketPrices(
        provinceId: state.selectedProvinceId,
        dateFrom: dateFrom,
      );
      state = state.copyWith(historicalPrices: history);
    } catch (_) {}
  }

  String _daysAgo(int n) {
    final d = DateTime.now().subtract(Duration(days: n));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

final marketPriceProvider =
    StateNotifierProvider<MarketPriceNotifier, MarketPriceState>((ref) {
  final service = ref.read(marketPriceServiceProvider);
  return MarketPriceNotifier(service);
});
