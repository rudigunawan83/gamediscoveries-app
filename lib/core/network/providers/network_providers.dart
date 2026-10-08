import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../app/config/app_config.dart';
import '../../logging/app_logger.dart';
import '../../storage/auth_token_storage.dart';
import '../api_client.dart';
import '../auth_interceptor.dart';
import '../connectivity_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((Ref ref) {
  return const FlutterSecureStorage();
});

final authTokenStorageProvider = Provider<AuthTokenStorage>((Ref ref) {
  return AuthTokenStorage(ref.watch(secureStorageProvider));
});

final connectivityProvider = Provider<Connectivity>((Ref ref) {
  return Connectivity();
});

final connectivityServiceProvider = Provider<ConnectivityService>((Ref ref) {
  return ConnectivityService(ref.watch(connectivityProvider));
});

final dioProvider = Provider<Dio>((Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref.watch(authTokenStorageProvider)));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (Object object) {
          ref.read(loggerProvider).d(object);
        },
      ),
    );
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((Ref ref) {
  return ApiClient(ref.watch(dioProvider));
});
