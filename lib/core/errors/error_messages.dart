import 'package:dio/dio.dart';

import '../network/api_exception.dart';

const Set<String> _networkErrorTypes = <String>{
  'connectionError',
  'connectionTimeout',
  'receiveTimeout',
  'sendTimeout',
};

String friendlyErrorMessage(Object error) {
  if (error is ApiException) {
    if (_networkErrorTypes.contains(error.type)) {
      return "You're offline or the connection is unstable. Please try again.";
    }

    return switch (error.statusCode) {
      401 => 'Your session has expired. Please sign in again.',
      403 => "You don't have access to this content.",
      404 => 'Content not found.',
      429 => 'Too many requests. Please try again shortly.',
      final int code when code >= 500 =>
        'Our servers are having trouble. Please try again later.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  if (error is DioException) {
    return "You're offline or the connection is unstable. Please try again.";
  }

  return 'Something went wrong. Please try again.';
}
