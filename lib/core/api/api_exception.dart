import 'package:dio/dio.dart';

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException e) {
    String message = 'An error occurred';
    int? statusCode = e.response?.statusCode;
    dynamic data = e.response?.data;

    if (e.response?.data is Map && e.response?.data['message'] != null) {
      message = e.response?.data['message'];
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection. Please check your network.';
          break;
        case DioExceptionType.badResponse:
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = 'Unauthorized. Please login again.';
              break;
            case 403:
              message = 'Access denied.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 500:
              message = 'Server error. Please try again later.';
              break;
            default:
              message = 'Something went wrong.';
          }
          break;
        case DioExceptionType.cancel:
          message = 'Request cancelled.';
          break;
        default:
          message = 'Something went wrong.';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => message;
}
