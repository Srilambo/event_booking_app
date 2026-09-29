import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return ApiException(
          message: data['message'] ?? 'An unexpected server error occurred',
          statusCode: error.response?.statusCode,
          errors: data['errors'] as List<dynamic>?,
        );
      }
      return ApiException(
        message: 'Server error (${error.response?.statusCode})',
        statusCode: error.response?.statusCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timed out. Please check your network.');
      case DioExceptionType.connectionError:
        return ApiException(message: 'Network connection failed. Ensure backend server is running.');
      default:
        return ApiException(message: 'Something went wrong: ${error.message}');
    }
  }

  @override
  String toString() => message;
}
