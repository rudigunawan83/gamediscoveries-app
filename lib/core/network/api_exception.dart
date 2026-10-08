import 'package:dio/dio.dart';

import 'models/api_envelope.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.type,
    this.traceId,
  });

  factory ApiException.fromErrorPayload(ApiErrorPayload payload) {
    return ApiException(
      message: payload.detail ?? payload.title,
      statusCode: payload.status,
      type: payload.type,
      traceId: payload.traceId,
    );
  }

  factory ApiException.fromDio(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final errorJson = responseData['error'];
        if (errorJson is Map<String, dynamic>) {
          return ApiException.fromErrorPayload(
            ApiErrorPayload.fromJson(errorJson),
          );
        }
      }

      return ApiException(
        message: error.message ?? 'Network request failed.',
        statusCode: error.response?.statusCode,
        type: error.type.name,
      );
    }

    return ApiException(message: 'Unexpected error.', type: 'unexpected');
  }

  final String message;
  final int? statusCode;
  final String? type;
  final String? traceId;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, type: $type, message: $message)';
  }
}
