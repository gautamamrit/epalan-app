import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/farm.dart';

/// Farm service for farm CRUD operations
class FarmService {
  final ApiClient _client = ApiClient.instance;

  /// Get all farms for current user
  Future<FarmsResponse> getFarms({
    int limit = 20,
    int offset = 0,
    String? search,
    int? districtId,
    bool includeDeleted = false,
  }) async {
    try {
      final response = await _client.get('/farms', queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (search != null) 'search': search,
        if (districtId != null) 'districtId': districtId.toString(),
        if (includeDeleted) 'includeDeleted': 'true',
      });

      if (response.data['success'] == true) {
        return FarmsResponse.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get farms');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get single farm by ID
  Future<Farm> getFarm(String farmId) async {
    try {
      final response = await _client.get('/farms/$farmId');

      if (response.data['success'] == true) {
        return Farm.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get farm');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create new farm
  Future<Farm> createFarm({
    required String name,
    required int countryId,
    required int provinceId,
    required int districtId,
    String? address,
    required List<Map<String, dynamic>> livestockTypes,
  }) async {
    try {
      final response = await _client.post('/farms', data: {
        'name': name,
        'countryId': countryId,
        'provinceId': provinceId,
        'districtId': districtId,
        if (address != null) 'address': address,
        'livestockTypes': livestockTypes,
      });

      if (response.data['success'] == true) {
        return Farm.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to create farm');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update farm
  Future<Farm> updateFarm(
    String farmId, {
    String? name,
    int? countryId,
    int? provinceId,
    int? districtId,
    String? address,
    bool? isActive,
  }) async {
    try {
      final response = await _client.patch('/farms/$farmId', data: {
        if (name != null) 'name': name,
        if (countryId != null) 'countryId': countryId,
        if (provinceId != null) 'provinceId': provinceId,
        if (districtId != null) 'districtId': districtId,
        if (address != null) 'address': address,
        if (isActive != null) 'isActive': isActive,
      });

      if (response.data['success'] == true) {
        return Farm.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to update farm');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Add livestock types to a farm
  Future<Farm> addLivestockTypes(
      String farmId, List<String> livestockTypeIds) async {
    try {
      final response = await _client.post('/farms/$farmId/livestock-types',
          data: {
            'livestockTypes':
                livestockTypeIds.map((id) => {'livestockTypeId': id}).toList(),
          });
      if (response.data['success'] == true) {
        return Farm.fromJson(response.data['data']);
      } else {
        throw ApiException(
            message:
                response.data['message'] ?? 'Failed to add livestock types');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Remove a livestock type from a farm (typeId = FarmLivestockType.id)
  Future<Farm> removeLivestockType(String farmId, String typeId) async {
    try {
      final response =
          await _client.delete('/farms/$farmId/livestock-types/$typeId');
      if (response.data['success'] == true) {
        return Farm.fromJson(response.data['data']);
      } else {
        throw ApiException(
            message:
                response.data['message'] ?? 'Failed to remove livestock type');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Delete farm
  Future<void> deleteFarm(String farmId) async {
    try {
      final response = await _client.delete('/farms/$farmId');

      if (response.data['success'] != true) {
        throw ApiException(message: response.data['message'] ?? 'Failed to delete farm');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
