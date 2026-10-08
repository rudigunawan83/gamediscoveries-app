import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_exception.dart';
import '../core/storage/local_preferences.dart';
import 'app.dart';

const int _maxAutoRetries = 2;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      retry: retryTransientErrors,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const GameDiscoveriesApp(),
    ),
  );
}

Duration? retryTransientErrors(int retryCount, Object error) {
  if (retryCount >= _maxAutoRetries) return null;

  if (error is ApiException) {
    final status = error.statusCode;
    if (status != null && status < 500 && status != 429) return null;
  }

  return Duration(seconds: 2 * (retryCount + 1));
}
