import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/models/auth_session_state.dart';
import '../../domain/models/auth_user.dart';

class AuthSessionController extends AsyncNotifier<AuthSessionState> {
  @override
  Future<AuthSessionState> build() async {
    try {
      return await ref.read(authRepositoryProvider).restoreSession();
    } catch (_) {
      return const AuthSessionState.guest();
    }
  }

  /// Throws on failure so the calling form can show the error; the global
  /// session state only changes on success.
  Future<void> login({required String email, required String password}) async {
    final next = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    state = AsyncData<AuthSessionState>(next);
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final next = await ref
        .read(authRepositoryProvider)
        .register(email: email, password: password, displayName: displayName);
    state = AsyncData<AuthSessionState>(next);
  }

  /// Applies a server-returned profile update (e.g. a new avatar) to the
  /// signed-in session.
  void updateUser(AuthUser user) {
    if (state.value?.isAuthenticated != true) {
      return;
    }
    state = AsyncData<AuthSessionState>(AuthSessionState.authenticated(user));
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = const AsyncData<AuthSessionState>(AuthSessionState.guest());
    }
  }
}

final authSessionControllerProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSessionState>(
      AuthSessionController.new,
    );

final isSignedInProvider = FutureProvider<bool>((Ref ref) async {
  final session = await ref.watch(authSessionControllerProvider.future);
  return session.isAuthenticated;
});
