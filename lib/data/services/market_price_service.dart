import '../models/market_price.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';

class MarketPriceService {
  final ApiClient _client = ApiClient.instance;

  Future<List<MarketPriceItem>> getItems() async {
    final response = await _client.get('/market-prices/items', queryParameters: {'isActive': 'true'});
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => MarketPriceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.data['message'] ?? 'Failed to load items');
  }

  Future<List<MarketPrice>> getLatestPrices({int? provinceId}) async {
    final params = <String, dynamic>{};
    if (provinceId != null) params['provinceId'] = provinceId.toString();
    final response = await _client.get('/market-prices/latest', queryParameters: params);
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => MarketPrice.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.data['message'] ?? 'Failed to load prices');
  }

  Future<List<MarketPrice>> getMarketPrices({int? provinceId, String? dateFrom}) async {
    final params = <String, dynamic>{};
    if (provinceId != null) params['provinceId'] = provinceId.toString();
    if (dateFrom != null) params['dateFrom'] = dateFrom;
    final response = await _client.get('/market-prices', queryParameters: params);
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => MarketPrice.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.data['message'] ?? 'Failed to load prices');
  }
}
