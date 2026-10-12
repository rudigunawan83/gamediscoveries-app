import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../network/providers/network_providers.dart';
import '../storage/local_preferences.dart';

typedef AnalyticsSender = Future<void> Function(List<Map<String, Object?>> events);

/// Screen views and searches for the admin Traffic dashboard. Events go to the
/// public ingest API; the server resolves the user from the JWT, so no user id
/// is ever sent from here.
class AppAnalytics {
  AppAnalytics({
    required this._send,
    required this._anonymousId,
    required this.platform,
    Future<String?> Function()? appVersion,
    DateTime Function()? clock,
    this.flushDelay = const Duration(seconds: 5),
  }) : _appVersionLoader = appVersion,
       _clock = clock ?? DateTime.now;

  static const String pageUrlBase = 'app://gamediscoveries';
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxQueue = 100;
  static const int batchSize = 20;

  final AnalyticsSender _send;
  final String Function() _anonymousId;
  final Future<String?> Function()? _appVersionLoader;
  final DateTime Function() _clock;

  /// `ANDROID` or `IOS`, as accepted by the ingest API.
  final String platform;
  final Duration flushDelay;

  final List<Map<String, Object?>> _queue = <Map<String, Object?>>[];
  String? _sessionId;
  DateTime? _lastActivity;
  String? _lastPath;
  String? _lastQuery;
  String? _appVersion;
  Timer? _timer;
  bool _flushing = false;
  bool _disposed = false;

  @visibleForTesting
  List<Map<String, Object?>> get pending => List.unmodifiable(_queue);

  void screenView(String path) {
    if (path.isEmpty || path == _lastPath) return;
    _lastPath = path;
    _enqueue('SCREEN_VIEW', path, const <String, Object?>{});
  }

  void search(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 2 || trimmed == _lastQuery) return;
    _lastQuery = trimmed;
    final value = trimmed.length > 100 ? trimmed.substring(0, 100) : trimmed;
    _enqueue('SEARCH', _lastPath ?? '/', <String, Object?>{'query': value});
  }

  void gameLoaded(String gameId, {required int loadMs}) {
    _enqueue(
      'GAME_LOADED',
      _lastPath ?? '/',
      <String, Object?>{'loadMs': loadMs},
      gameId: gameId,
    );
  }

  void gameLoadFailed(String gameId, {required String reason}) {
    _enqueue(
      'GAME_LOAD_FAILED',
      _lastPath ?? '/',
      <String, Object?>{'reason': reason},
      gameId: gameId,
    );
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_flushing || _queue.isEmpty || _disposed) return;

    _flushing = true;
    final batch = List<Map<String, Object?>>.of(_queue.take(batchSize));
    _queue.removeRange(0, batch.length);
    try {
      await _send(batch);
    } catch (_) {
      // Analytics must never break the app; keep the events for the next flush.
      _queue.insertAll(0, batch);
      _trim();
    } finally {
      _flushing = false;
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }

  void _enqueue(
    String eventType,
    String path,
    Map<String, Object?> metadata, {
    String? gameId,
  }) {
    if (_disposed) return;
    final now = _clock().toUtc();
    _queue.add(<String, Object?>{
      'eventId': const Uuid().v4(),
      'eventType': eventType,
      'anonymousId': _anonymousId(),
      'sessionId': _session(now),
      'gameId': ?gameId,
      'source': 'MOBILE',
      'platform': platform,
      'deviceType': 'MOBILE',
      'appVersion': _appVersion,
      'pageUrl': '$pageUrlBase$path',
      'metadata': metadata,
      'occurredAt': now.toIso8601String(),
    });
    _trim();
    _loadAppVersion();

    if (_queue.length >= batchSize) {
      unawaited(flush());
    } else {
      _timer ??= Timer(flushDelay, () => unawaited(flush()));
    }
  }

  String _session(DateTime now) {
    final last = _lastActivity;
    if (_sessionId == null ||
        last == null ||
        now.difference(last) > sessionTimeout) {
      _sessionId = const Uuid().v4();
    }
    _lastActivity = now;
    return _sessionId!;
  }

  void _trim() {
    if (_queue.length > maxQueue) {
      _queue.removeRange(0, _queue.length - maxQueue);
    }
  }

  void _loadAppVersion() {
    final loader = _appVersionLoader;
    if (_appVersion != null || loader == null) return;
    unawaited(
      loader().then((String? version) => _appVersion = version).catchError(
        (Object _) => null,
      ),
    );
  }
}

final appAnalyticsProvider = Provider<AppAnalytics>((Ref ref) {
  final api = ref.watch(apiClientProvider);
  final prefs = ref.watch(localPreferencesProvider);
  final analytics = AppAnalytics(
    send: (List<Map<String, Object?>> events) => api.postAction(
      '/api/v1/events/batch',
      body: <String, Object?>{'events': events},
    ),
    anonymousId: () => prefs.anonymousId,
    platform: defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID',
    appVersion: () async {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    },
  );
  final lifecycle = AppLifecycleListener(
    onHide: () => unawaited(analytics.flush()),
  );
  ref.onDispose(() {
    lifecycle.dispose();
    analytics.dispose();
  });
  return analytics;
});
