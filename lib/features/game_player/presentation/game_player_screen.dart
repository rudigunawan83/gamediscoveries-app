import 'dart:async';
import 'dart:convert' show HtmlEscape, HtmlEscapeMode;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/logging/app_logger.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../../favorites/data/library_repository.dart';
import '../../favorites/presentation/library_providers.dart';
import '../../game_detail/domain/game_detail.dart';
import '../../game_detail/presentation/game_detail_providers.dart';
import '../../missions/presentation/missions_providers.dart';
import '../../progress/presentation/progress_providers.dart';
import '../data/game_session_repository.dart';

const Duration _heartbeatInterval = Duration(seconds: 30);

/// Fullscreen gameplay in the game's designed orientation. Call before
/// navigating to the player (when the orientation is known) to avoid a
/// wrong-orientation frame flashing first.
void enterGameDisplayMode({required bool landscape}) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
    landscape
        ? <DeviceOrientation>[
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : <DeviceOrientation>[DeviceOrientation.portraitUp],
  );
}

void exitGameDisplayMode() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
}

class GamePlayerScreen extends ConsumerStatefulWidget {
  const GamePlayerScreen({required this.slug, this.initialGame, super.key});

  final String slug;
  final GameDetail? initialGame;

  @override
  ConsumerState<GamePlayerScreen> createState() => _GamePlayerScreenState();
}

class _GamePlayerScreenState extends ConsumerState<GamePlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    exitGameDisplayMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.initialGame;
    if (ready != null) return _PlayerView(game: ready);

    final detail = ref.watch(gameDetailProvider(widget.slug));
    return detail.when(
      data: (GameDetail game) => _PlayerView(game: game),
      loading: () =>
          const Scaffold(backgroundColor: Colors.black, body: LoadingView()),
      error: (Object error, StackTrace stackTrace) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          error: error,
          onRetry: () => ref.invalidate(gameDetailProvider(widget.slug)),
        ),
      ),
    );
  }
}

class _PlayerView extends ConsumerStatefulWidget {
  const _PlayerView({required this.game});

  final GameDetail game;

  @override
  ConsumerState<_PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<_PlayerView>
    with WidgetsBindingObserver {
  late final WebViewController _web;
  late final GameSessionRepository _sessions;
  late final LibraryRepository _library;
  late final bool _signedIn;
  late final Logger _logger;
  final Stopwatch _played = Stopwatch();

  String? _sessionId;
  Timer? _heartbeat;
  bool _loading = true;
  bool _paused = false;
  bool _ended = false;
  bool _loadStarted = false;
  bool _orientationTimedOut = false;
  Timer? _orientationTimeout;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessions = ref.read(gameSessionRepositoryProvider);
    _library = ref.read(libraryRepositoryProvider);
    _signedIn = ref.read(isSignedInProvider).value ?? false;
    _logger = ref.read(loggerProvider);

    enterGameDisplayMode(landscape: widget.game.isLandscape);
    _web = _createWebView();
    _orientationTimeout = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _orientationTimedOut = true);
    });
    _startSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orientationTimeout?.cancel();
    _heartbeat?.cancel();
    if (!_ended) unawaited(_endSession());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final id = _sessionId;
    if (id == null || _ended) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _played.stop();
      _heartbeat?.cancel();
      _safe(() => _sessions.pause(id));
    } else if (state == AppLifecycleState.resumed && !_paused) {
      _played.start();
      _safe(() => _sessions.resume(id));
      _startHeartbeat();
    }
  }

  WebViewController _createWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              _loading = false;
              _loadError = 'The game could not be loaded.';
            });
          },
          // The main frame is our host page; anything trying to replace it
          // (ads, outbound links) is blocked while the game iframe navigates
          // freely.
          onNavigationRequest: (NavigationRequest request) =>
              request.isMainFrame && !_loading
              ? NavigationDecision.prevent
              : NavigationDecision.navigate,
        ),
      );

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    final url = Uri.tryParse(widget.game.playUrl ?? '');
    if (url == null || !url.hasScheme) {
      _loading = false;
      _loadError = 'This game is not available on mobile yet.';
    }
    return controller;
  }

  /// Loads only once the screen is in the game's orientation, so the page's
  /// first layout already uses the final viewport size.
  void _startLoadIfReady(Size size) {
    if (_loadStarted || _loadError != null) return;
    final ready =
        (size.width > size.height) == widget.game.isLandscape ||
        _orientationTimedOut;
    if (!ready) return;

    setState(() => _loadStarted = true);
    _orientationTimeout?.cancel();
    final url = Uri.parse(widget.game.playUrl!);
    _web.loadHtmlString(_hostPage(url), baseUrl: '${AppConfig.webBaseUrl}/');
  }

  /// Mirrors the web player: the game runs inside a full-viewport iframe so
  /// fixed-size canvases scale to the screen. The page itself has no scripts.
  static String _hostPage(Uri gameUrl) {
    final src = const HtmlEscape(HtmlEscapeMode.attribute).convert('$gameUrl');
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: #000; }
  iframe { position: fixed; inset: 0; width: 100vw; height: 100vh; border: 0; display: block; }
</style>
</head>
<body>
<iframe src="$src"
  sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-pointer-lock allow-orientation-lock"
  allow="fullscreen; autoplay; encrypted-media; gamepad; accelerometer; gyroscope; pointer-lock"
  allowfullscreen referrerpolicy="no-referrer-when-downgrade"></iframe>
</body>
</html>
''';
  }

  Future<void> _startSession() async {
    try {
      final id = await _sessions.start(
        widget.game.id,
        platform: Platform.isIOS ? 'IOS' : 'ANDROID',
      );
      if (id.isEmpty) return;
      _sessionId = id;
      if (!mounted || _ended) {
        unawaited(_sessions.end(id));
        return;
      }
      _played.start();
      _startHeartbeat();
    } catch (error) {
      _logger.w('Game session start failed: $error');
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) {
      final id = _sessionId;
      if (id != null) _safe(() => _sessions.heartbeat(id, focused: !_paused));
    });
  }

  void _setPaused(bool paused) {
    if (_paused == paused) return;
    setState(() => _paused = paused);

    final id = _sessionId;
    if (id == null) return;
    if (paused) {
      _played.stop();
      _safe(() => _sessions.pause(id));
    } else {
      _played.start();
      _safe(() => _sessions.resume(id));
    }
  }

  Future<void> _endSession() async {
    _ended = true;
    _heartbeat?.cancel();
    _played.stop();

    final id = _sessionId;
    if (id != null) await _safe(() => _sessions.end(id));
    if (_signedIn) {
      await _safe(
        () => _library.recordHistory(
          widget.game.id,
          durationSeconds: _played.elapsed.inSeconds,
        ),
      );
    }
  }

  Future<void> _exit() async {
    await _endSession();
    if (!mounted) return;

    if (_signedIn) {
      ref
        ..invalidate(playHistoryProvider)
        ..invalidate(myProgressProvider)
        ..invalidate(myMissionsProvider);
    }
    exitGameDisplayMode();
    if (context.canPop()) context.pop();
  }

  void _restart() {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _setPaused(false);
    _web.reload();
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _logger.w('Game session call failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _loadError;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _paused ? _exit() : _setPaused(true);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              _body(constraints.biggest, error),
        ),
      ),
    );
  }

  Widget _body(Size size, String? error) {
    if (!_loadStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startLoadIfReady(size);
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (_loadStarted) WebViewWidget(controller: _web),
        if (_loading)
          const Positioned.fill(
            child: ColoredBox(color: Colors.black, child: LoadingView()),
          ),
        if (error != null)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.night,
              child: MessageView(
                icon: Icons.videogame_asset_off_rounded,
                title: 'Game unavailable',
                message: error,
                actionLabel: 'Back',
                onAction: _exit,
              ),
            ),
          ),
        if (_paused)
          Positioned.fill(
            child: _PauseOverlay(
              title: widget.game.title,
              onResume: () => _setPaused(false),
              onRestart: _restart,
              onExit: _exit,
            ),
          ),
        if (!_paused && error == null)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _RoundButton(
                  icon: Icons.pause_rounded,
                  tooltip: 'Pause',
                  onPressed: () => _setPaused(true),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.title,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  final String title;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Icon(
                  Icons.pause_circle_filled_rounded,
                  color: AppColors.gold,
                  size: 56,
                ),
                const SizedBox(height: 10),
                Text(
                  'Paused',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restart'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Exit Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
