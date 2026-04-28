import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/farm_member.dart';

class FarmMemberService {
  final ApiClient _client = ApiClient.instance;

  /// List members and pending invites for a farm
  Future<({List<FarmMember> members, List<FarmInvite> invites})> getMembers(
      String farmId) async {
    try {
      final response = await _client.get('/farms/$farmId/members');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final members = (data['members'] as List)
            .map((m) => FarmMember.fromJson(m))
            .toList();
        final invites = (data['invites'] as List)
            .map((i) => FarmInvite.fromJson(i))
            .toList();
        return (members: members, invites: invites);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load members');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create a user and add them to the farm (same flow as admin)
  Future<void> createAndInvite(
    String farmId, {
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    int? countryId,
    int? districtId,
    String? address,
    required String role,
  }) async {
    try {
      final response = await _client.post('/users', data: {
        'firstName': firstName,
        'lastName': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (countryId != null) 'countryId': countryId,
        if (districtId != null) 'districtId': districtId,
        if (address != null && address.isNotEmpty) 'address': address,
        'types': ['farmer'],
        'memberships': [
          {
            'entityType': 'farm',
            'entityId': farmId,
            'role': role,
          }
        ],
      });
      if (response.data['success'] != true) {
        throw ApiException(
            message: response.data['message'] ?? 'Failed to create user');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Cancel a pending invite
  Future<void> cancelInvite(String farmId, String inviteId) async {
    try {
      final response =
          await _client.delete('/farms/$farmId/members/invites/$inviteId');
      if (response.data['success'] != true) {
        throw ApiException(message: response.data['message'] ?? 'Failed to cancel invite');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update a member's role
  Future<void> updateRole(
      String farmId, String membershipId, String role) async {
    try {
      final response =
          await _client.patch('/farms/$farmId/members/$membershipId', data: {
        'role': role,
      });
      if (response.data['success'] != true) {
        throw ApiException(message: response.data['message'] ?? 'Failed to update role');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Remove a member from the farm
  Future<void> removeMember(String farmId, String membershipId) async {
    try {
      final response =
          await _client.delete('/farms/$farmId/members/$membershipId');
      if (response.data['success'] != true) {
        throw ApiException(message: response.data['message'] ?? 'Failed to remove member');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
