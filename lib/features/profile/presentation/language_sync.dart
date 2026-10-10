import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_language.dart';
import '../../../core/storage/local_preferences.dart';
import '../../auth/domain/models/auth_session_state.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/preferences_repository.dart';

/// Keeps the language choice in sync with the signed-in account.
///
/// Conflict policy, applied when a user signs in or a session is restored:
/// - a choice made on this device that was never saved to the account
///   (picked as a guest, or saved while offline) wins and is uploaded;
/// - otherwise the account's language replaces the local one.
/// Changes made while signed in are uploaded right away.
final languageSyncProvider = Provider<void>((Ref ref) {
  final sync = _LanguageSync(ref);
  ref.listen<AsyncValue<AuthSessionState>>(
    authSessionControllerProvider,
    (_, AsyncValue<AuthSessionState> next) => sync.onSession(next.value),
    fireImmediately: true,
  );
  ref.listen<AppLanguage>(
    appLanguageProvider,
    (_, _) => unawaited(sync.upload()),
  );
});

class _LanguageSync {
  _LanguageSync(this._ref);

  final Ref _ref;
  String? _userId;
  bool _uploading = false;

  LocalPreferences get _prefs => _ref.read(localPreferencesProvider);

  void onSession(AuthSessionState? session) {
    final user = session?.isAuthenticated == true ? session?.user : null;
    if (user?.id == _userId) return;
    _userId = user?.id;
    if (user == null) return;

    if (_prefs.appLanguageNeedsSync) {
      unawaited(upload());
      return;
    }
    final saved = AppLanguage.tryFromCode(user.preferredLanguage);
    if (saved != null && saved != _ref.read(appLanguageProvider)) {
      unawaited(_ref.read(appLanguageProvider.notifier).adopt(saved));
    }
  }

  Future<void> upload() async {
    final userId = _userId;
    if (userId == null || _uploading || !_prefs.appLanguageNeedsSync) return;

    _uploading = true;
    try {
      AppLanguage sent;
      do {
        sent = _ref.read(appLanguageProvider);
        final user = await _ref
            .read(preferencesRepositoryProvider)
            .updateLanguage(sent);
        if (_userId != userId) return;
        _ref.read(authSessionControllerProvider.notifier).updateUser(user);
      } while (_ref.read(appLanguageProvider) != sent);
      await _prefs.setAppLanguageNeedsSync(false);
    } catch (_) {
      // Stays marked for sync and is retried on the next sign-in or change.
    } finally {
      _uploading = false;
    }
  }
}
