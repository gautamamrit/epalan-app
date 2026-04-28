import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/livestock.dart';

/// Livestock service for fetching categories and breeds
class LivestockService {
  final ApiClient _client = ApiClient.instance;

  /// Get all active livestock categories
  Future<List<LivestockCategory>> getCategories({String? subtypeId}) async {
    try {
      final response = await _client.get('/livestock/categories', queryParameters: {
        if (subtypeId != null) 'subtypeId': subtypeId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((c) => LivestockCategory.fromJson(c)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get categories');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all active breeds for a category
  Future<List<LivestockBreed>> getBreeds({String? categoryId}) async {
    try {
      final response = await _client.get('/livestock/breeds', queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((b) => LivestockBreed.fromJson(b)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get breeds');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all active livestock types
  Future<List<LivestockType>> getTypes() async {
    try {
      final response = await _client.get('/livestock/types');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((t) => LivestockType.fromJson(t)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get types');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all active livestock subtypes
  Future<List<LivestockSubtype>> getSubtypes({String? typeId}) async {
    try {
      final response = await _client.get('/livestock/subtypes', queryParameters: {
        if (typeId != null) 'typeId': typeId,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((s) => LivestockSubtype.fromJson(s)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get subtypes');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
