import 'package:dio/dio.dart';

import '../utils/json_parsing.dart';
import 'api_exception.dart';
import 'models/api_envelope.dart';
import 'models/paged_result.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) parser,
  }) async {
    final envelope = await _send<T>(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
      parser,
    );
    return _requireData(envelope);
  }

  Future<PagedResult<T>> getPaged<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) itemParser,
  }) async {
    final envelope = await _send<List<T>>(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
      (Object? json) => parseJsonList(json, itemParser),
    );
    final items = _requireData(envelope);
    final meta = envelope.meta;

    return PagedResult<T>(
      items: items,
      page: meta?.page ?? 1,
      pageSize: meta?.pageSize ?? items.length,
      total: meta?.total ?? items.length,
      totalPages: meta?.totalPages ?? 1,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) parser,
  }) async {
    final envelope = await _send<T>(
      () => _dio.post<Object?>(
        path,
        data: body,
        queryParameters: queryParameters,
      ),
      parser,
    );
    return _requireData(envelope);
  }

  Future<T> delete<T>(
    String path, {
    Object? body,
    required T Function(Object? json) parser,
  }) async {
    final envelope = await _send<T>(
      () => _dio.delete<Object?>(path, data: body),
      parser,
    );
    return _requireData(envelope);
  }

  Future<void> postAction(String path, {Object? body}) async {
    await _send<Object?>(
      () => _dio.post<Object?>(path, data: body ?? const <String, dynamic>{}),
      (Object? json) => json,
      allowEmptyBody: true,
    );
  }

  Future<void> putAction(String path, {Object? body}) async {
    await _send<Object?>(
      () => _dio.put<Object?>(path, data: body ?? const <String, dynamic>{}),
      (Object? json) => json,
      allowEmptyBody: true,
    );
  }

  Future<void> deleteAction(String path) async {
    await _send<Object?>(
      () => _dio.delete<Object?>(path),
      (Object? json) => json,
      allowEmptyBody: true,
    );
  }

  Future<ApiEnvelope<T>> _send<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object? json) parser, {
    bool allowEmptyBody = false,
  }) async {
    final Response<Object?> response;
    try {
      response = await request();
    } catch (error) {
      throw ApiException.fromDio(error);
    }

    final raw = response.data;
    if (allowEmptyBody && (raw == null || raw == '')) {
      return ApiEnvelope<T>(success: true);
    }

    if (raw is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'Invalid response format.',
        type: 'invalid_response',
      );
    }

    final envelope = ApiEnvelope<T>.fromJson(raw, parser);
    if (!envelope.success) {
      final payload = envelope.error;
      if (payload != null) {
        throw ApiException.fromErrorPayload(payload);
      }

      throw const ApiException(
        message: 'Request failed without an error payload.',
        type: 'request_failed',
      );
    }

    return envelope;
  }

  T _requireData<T>(ApiEnvelope<T> envelope) {
    final data = envelope.data;
    if (data == null) {
      throw const ApiException(
        message: 'Response data is missing.',
        type: 'missing_data',
      );
    }

    return data;
  }
}
