import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/animal.dart';

/// Animal service for animal CRUD and related operations
class AnimalService {
  final ApiClient _client = ApiClient.instance;

  /// Get all animals for a farm
  Future<List<Animal>> getAnimals(
    String farmId, {
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get('/farms/$farmId/animals', queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (status != null) 'status': status,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((b) => Animal.fromJson(b)).toList();
        } else if (data is Map && data['animals'] != null) {
          return (data['animals'] as List).map((b) => Animal.fromJson(b)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get animals');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get animal detail with stats
  Future<AnimalDetail> getAnimalDetail(String farmId, String animalId) async {
    try {
      final response = await _client.get('/farms/$farmId/animals/$animalId');

      if (response.data['success'] == true) {
        return AnimalDetail.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get animal');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create new animal
  Future<Animal> createAnimal(
    String farmId, {
    required String categoryId,
    String? breedId,
    String? name,
    required DateTime startDate,
    // Group fields
    int? initialQuantity,
    // Individual fields
    String? tagNumber,
    String? sex,
    DateTime? dateOfBirth,
    String? shortCode,
    // Source
    String? sourceType,
    String? sourceOrderId,
    String? sourceNotes,
  }) async {
    try {
      final response = await _client.post('/farms/$farmId/animals', data: {
        'categoryId': categoryId,
        if (breedId != null) 'breedId': breedId,
        if (name != null) 'name': name,
        'startDate': startDate.toIso8601String().split('T')[0],
        if (initialQuantity != null) 'initialQuantity': initialQuantity,
        if (tagNumber != null) 'tagNumber': tagNumber,
        if (sex != null) 'sex': sex,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0],
        if (shortCode != null) 'shortCode': shortCode,
        if (sourceType != null) 'sourceType': sourceType,
        if (sourceOrderId != null) 'sourceOrderId': sourceOrderId,
        if (sourceNotes != null) 'sourceNotes': sourceNotes,
      });

      if (response.data['success'] == true) {
        return Animal.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to create animal');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update animal (including status changes)
  Future<Animal> updateAnimal(
    String farmId,
    String animalId, {
    String? name,
    String? breedId,
    int? initialQuantity,
    DateTime? startDate,
    String? sourceType,
    String? sourceNotes,
    String? status,
    DateTime? endDate,
    String? endNotes,
    int? saleCount,
    double? saleWeightKg,
    double? salePricePerKg,
    double? saleTotal,
  }) async {
    try {
      final response = await _client.patch('/farms/$farmId/animals/$animalId', data: {
        if (name != null) 'name': name,
        if (breedId != null) 'breedId': breedId,
        if (initialQuantity != null) 'initialQuantity': initialQuantity,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (sourceType != null) 'sourceType': sourceType,
        if (sourceNotes != null) 'sourceNotes': sourceNotes,
        if (status != null) 'status': status,
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        if (endNotes != null) 'endNotes': endNotes,
        if (saleCount != null) 'saleCount': saleCount,
        if (saleWeightKg != null) 'saleWeightKg': saleWeightKg,
        if (salePricePerKg != null) 'salePricePerKg': salePricePerKg,
        if (saleTotal != null) 'saleTotal': saleTotal,
      });

      if (response.data['success'] == true) {
        return Animal.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to update animal');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================================
  // DAILY RECORDS
  // ============================================================================

  /// Get daily records for an animal
  Future<List<DailyRecord>> getDailyRecords(
    String farmId,
    String animalId, {
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        '/farms/$farmId/animals/$animalId/records',
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((r) => DailyRecord.fromJson(r)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get records');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create daily record
  Future<DailyRecord> createDailyRecord(
    String farmId,
    String animalId, {
    required DateTime recordDate,
    int? mortalityCount,
    String? mortalityReason,
    double? feedConsumedKg,
    int? sampleCount,
    double? sampleWeightKg,
    int? eggsCollected,
    String? notes,
  }) async {
    try {
      final response = await _client.post('/farms/$farmId/animals/$animalId/records', data: {
        'recordDate': recordDate.toIso8601String().split('T')[0],
        if (mortalityCount != null) 'mortalityCount': mortalityCount,
        if (mortalityReason != null) 'mortalityReason': mortalityReason,
        if (feedConsumedKg != null) 'feedConsumedKg': feedConsumedKg,
        if (sampleCount != null) 'sampleCount': sampleCount,
        if (sampleWeightKg != null) 'sampleWeightKg': sampleWeightKg,
        if (eggsCollected != null) 'eggsCollected': eggsCollected,
        if (notes != null) 'notes': notes,
      });

      if (response.data['success'] == true) {
        return DailyRecord.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to create record');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DailyRecord> updateDailyRecord(
    String farmId,
    String animalId,
    String recordId, {
    int? mortalityCount,
    String? mortalityReason,
    double? feedConsumedKg,
    int? sampleCount,
    double? sampleWeightKg,
    int? eggsCollected,
    String? notes,
  }) async {
    try {
      final response = await _client.patch(
          '/farms/$farmId/animals/$animalId/records/$recordId',
          data: {
            'mortalityCount': mortalityCount ?? 0,
            if (mortalityReason != null) 'mortalityReason': mortalityReason,
            if (feedConsumedKg != null) 'feedConsumedKg': feedConsumedKg,
            if (sampleCount != null) 'sampleCount': sampleCount,
            if (sampleWeightKg != null) 'sampleWeightKg': sampleWeightKg,
            if (eggsCollected != null) 'eggsCollected': eggsCollected,
            if (notes != null) 'notes': notes,
          });

      if (response.data['success'] == true) {
        return DailyRecord.fromJson(response.data['data']);
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'Failed to update record');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteDailyRecord(
    String farmId,
    String animalId,
    String recordId,
  ) async {
    try {
      final response = await _client.delete(
        '/farms/$farmId/animals/$animalId/records/$recordId',
      );
      if (response.data['success'] != true) {
        throw ApiException(
            message: response.data['message'] ?? 'Failed to delete record');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================================
  // VACCINATIONS
  // ============================================================================

  /// Get vaccinations for an animal
  Future<List<Vaccination>> getVaccinations(String farmId, String animalId) async {
    try {
      final response = await _client.get('/farms/$farmId/animals/$animalId/vaccinations');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((v) => Vaccination.fromJson(v)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get vaccinations');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Complete vaccination
  Future<Vaccination> completeVaccination(
    String farmId,
    String animalId,
    String vaccinationId, {
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        '/farms/$farmId/animals/$animalId/vaccinations/$vaccinationId/complete',
        data: {
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return Vaccination.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to complete vaccination');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================================
  // MEDICATIONS
  // ============================================================================

  /// Get medications for an animal
  Future<List<Medication>> getMedications(String farmId, String animalId) async {
    try {
      final response = await _client.get('/farms/$farmId/animals/$animalId/medications');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((m) => Medication.fromJson(m)).toList();
        }
        return [];
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get medications');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Complete medication
  Future<Medication> completeMedication(
    String farmId,
    String animalId,
    String medicationId, {
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        '/farms/$farmId/animals/$animalId/medications/$medicationId/complete',
        data: {
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return Medication.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to complete medication');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================================
  // HEALTH PROGRAMS
  // ============================================================================

  /// Get available vaccination programs for a category
  Future<List<HealthProgram>> getVaccinationPrograms(String categoryId) async {
    try {
      final response = await _client.get(
        '/health-programs/vaccination',
        queryParameters: {'categoryId': categoryId},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((p) => HealthProgram.fromJson(p)).toList();
        }
        return [];
      }
      return [];
    } on DioException {
      return [];
    }
  }

  /// Get available medication programs for a category
  Future<List<HealthProgram>> getMedicationPrograms(String categoryId) async {
    try {
      final response = await _client.get(
        '/health-programs/medication',
        queryParameters: {'categoryId': categoryId},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((p) => HealthProgram.fromJson(p)).toList();
        }
        return [];
      }
      return [];
    } on DioException {
      return [];
    }
  }

  /// Apply vaccination program to an animal
  Future<({int applied, int skipped})> applyVaccinationProgram(
    String farmId,
    String animalId,
    String programId,
  ) async {
    try {
      final response = await _client.post(
        '/farms/$farmId/animals/$animalId/vaccinations/apply-program',
        data: {'programId': programId},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return (
          applied: (data['applied'] as int?) ?? 0,
          skipped: (data['skipped'] as int?) ?? 0,
        );
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to apply program');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Apply medication program to an animal
  Future<({int applied, int skipped})> applyMedicationProgram(
    String farmId,
    String animalId,
    String programId,
  ) async {
    try {
      final response = await _client.post(
        '/farms/$farmId/animals/$animalId/medications/apply-program',
        data: {'programId': programId},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return (
          applied: (data['applied'] as int?) ?? 0,
          skipped: (data['skipped'] as int?) ?? 0,
        );
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to apply program');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get vaccination program with schedule items
  Future<HealthProgramDetail?> getVaccinationProgramDetail(String programId) async {
    try {
      final response = await _client.get('/health-programs/vaccination/$programId');
      if (response.data['success'] == true) {
        return HealthProgramDetail.fromJson(response.data['data']);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  /// Get medication program with schedule items
  Future<HealthProgramDetail?> getMedicationProgramDetail(String programId) async {
    try {
      final response = await _client.get('/health-programs/medication/$programId');
      if (response.data['success'] == true) {
        return HealthProgramDetail.fromJson(response.data['data']);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  /// Add individual vaccination
  Future<Vaccination> addVaccination(
    String farmId,
    String animalId, {
    required String vaccineName,
    required int fromDay,
    required int toDay,
    required String dueFromDate,
    required String dueToDate,
    String? route,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        '/farms/$farmId/animals/$animalId/vaccinations',
        data: {
          'vaccineName': vaccineName,
          'fromDay': fromDay,
          'toDay': toDay,
          'dueFromDate': dueFromDate,
          'dueToDate': dueToDate,
          if (route != null) 'route': route,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.data['success'] == true) {
        return Vaccination.fromJson(response.data['data']);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to add vaccination');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Add individual medication
  Future<Medication> addMedication(
    String farmId,
    String animalId, {
    required String medicationName,
    required int fromDay,
    required int toDay,
    required String dueFromDate,
    required String dueToDate,
    String? purpose,
    String? dosage,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        '/farms/$farmId/animals/$animalId/medications',
        data: {
          'medicationName': medicationName,
          'fromDay': fromDay,
          'toDay': toDay,
          'dueFromDate': dueFromDate,
          'dueToDate': dueToDate,
          if (purpose != null) 'purpose': purpose,
          if (dosage != null) 'dosage': dosage,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.data['success'] == true) {
        return Medication.fromJson(response.data['data']);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to add medication');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all pending health alerts for a farm (single API call)
  Future<({List<Vaccination> vaccinations, List<Medication> medications})>
      getFarmAlerts(String farmId) async {
    try {
      final response = await _client.get('/farms/$farmId/alerts');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final vaccinations = (data['vaccinations'] as List? ?? [])
            .map((v) => Vaccination.fromJson(v))
            .toList();
        final medications = (data['medications'] as List? ?? [])
            .map((m) => Medication.fromJson(m))
            .toList();
        return (vaccinations: vaccinations, medications: medications);
      }
      return (vaccinations: <Vaccination>[], medications: <Medication>[]);
    } catch (_) {
      return (vaccinations: <Vaccination>[], medications: <Medication>[]);
    }
  }

  Future<void> deleteAnimal(String farmId, String animalId) async {
    try {
      final response = await _client.delete(
        '/farms/$farmId/animals/$animalId',
      );

      if (response.data['success'] != true) {
        throw ApiException(
            message: response.data['message'] ?? 'Failed to delete animal');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
