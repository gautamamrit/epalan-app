import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';

class LocationProvince {
  final int id;
  final String name;

  LocationProvince({required this.id, required this.name});

  factory LocationProvince.fromJson(Map<String, dynamic> json) =>
      LocationProvince(id: json['id'], name: json['name']);
}

class LocationDistrict {
  final int id;
  final String name;

  LocationDistrict({required this.id, required this.name});

  factory LocationDistrict.fromJson(Map<String, dynamic> json) =>
      LocationDistrict(id: json['id'], name: json['name']);
}

class LocationService {
  final ApiClient _client = ApiClient.instance;

  Future<List<LocationProvince>> getProvinces({int countryId = 1}) async {
    try {
      final response = await _client.get('/locations/provinces', queryParameters: {
        'countryId': countryId,
      });
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((p) => LocationProvince.fromJson(p)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load provinces');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<LocationDistrict>> getDistricts({required int provinceId}) async {
    try {
      final response = await _client.get('/locations/districts', queryParameters: {
        'provinceId': provinceId,
      });
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((d) => LocationDistrict.fromJson(d)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load districts');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
