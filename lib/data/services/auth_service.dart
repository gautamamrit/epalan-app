import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/user.dart';

/// Auth service for login, register, logout
class AuthService {
  final ApiClient _client = ApiClient.instance;

  /// Login with email/phone and password
  Future<AuthResponse> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _client.post('/auth/login', data: {
        'emailOrPhone': emailOrPhone,
        'password': password,
      });

      if (response.data['success'] == true) {
        final authResponse = AuthResponse.fromJson(response.data['data']);

        // Save tokens
        await _client.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        return authResponse;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Register new user
  Future<User> register({
    required String firstName,
    required String lastName,
    String? middleName,
    String? email,
    String? phone,
    required String password,
    String language = 'ne',
  }) async {
    try {
      final response = await _client.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        if (middleName != null) 'middleName': middleName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
        'language': language,
      });

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get current user profile
  Future<User> getMe() async {
    try {
      final response = await _client.get('/auth/me');

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Logout - revoke refresh token and clear local tokens
  Future<void> logout() async {
    try {
      final refreshToken = await _client.getRefreshToken();
      if (refreshToken != null) {
        await _client.post('/auth/logout', data: {
          'refreshToken': refreshToken,
        });
      }
    } catch (_) {
      // Ignore logout errors
    } finally {
      await _client.clearTokens();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _client.isAuthenticated();
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post('/auth/me/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.data['success'] != true) {
        throw ApiException(message: response.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phone,
    String? language,
  }) async {
    try {
      final response = await _client.patch('/auth/me', data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (middleName != null) 'middleName': middleName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (language != null) 'language': language,
      });

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
