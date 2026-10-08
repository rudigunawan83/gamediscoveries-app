import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/network/api_client.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _clientWith(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  return ApiClient(dio);
}

void main() {
  group('ApiClient.getPaged', () {
    test('parses items and pagination meta', () async {
      final adapter = _FakeAdapter(200, <String, Object?>{
        'success': true,
        'data': <Map<String, Object?>>[
          <String, Object?>{'id': 'a'},
          <String, Object?>{'id': 'b'},
        ],
        'error': null,
        'meta': <String, Object?>{
          'page': 1,
          'pageSize': 2,
          'total': 5,
          'totalPages': 3,
        },
      });

      final result = await _clientWith(adapter).getPaged<String>(
        '/api/v1/games',
        queryParameters: <String, dynamic>{'page': 1, 'pageSize': 2},
        itemParser: (Map<String, dynamic> json) => json['id'] as String,
      );

      expect(result.items, <String>['a', 'b']);
      expect(result.total, 5);
      expect(result.totalPages, 3);
      expect(result.hasMore, isTrue);
      expect(adapter.lastRequest?.queryParameters['pageSize'], 2);
    });
  });

  group('ApiClient error handling', () {
    test('maps HTTP error payload to ApiException', () async {
      final adapter = _FakeAdapter(404, <String, Object?>{
        'success': false,
        'data': null,
        'error': <String, Object?>{
          'type': 'not_found',
          'title': 'Not Found',
          'status': 404,
          'detail': 'Game not found.',
        },
        'meta': null,
      });

      await expectLater(
        _clientWith(
          adapter,
        ).get<Object?>('/api/v1/games/x', parser: (Object? json) => json),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 404)
              .having(
                (ApiException e) => e.message,
                'message',
                'Game not found.',
              ),
        ),
      );
    });

    test('keeps envelope failure details on a 200 response', () async {
      final adapter = _FakeAdapter(200, <String, Object?>{
        'success': false,
        'data': null,
        'error': <String, Object?>{
          'type': 'validation_error',
          'title': 'Validation Error',
          'status': 422,
        },
        'meta': null,
      });

      await expectLater(
        _clientWith(
          adapter,
        ).get<Object?>('/api/v1/games', parser: (Object? json) => json),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 422)
              .having((ApiException e) => e.type, 'type', 'validation_error'),
        ),
      );
    });
  });
}
