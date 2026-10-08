import 'auth_user.dart';

enum AuthStatus { guest, authenticated }

class AuthSessionState {
  const AuthSessionState._({required this.status, this.user});

  const AuthSessionState.guest() : this._(status: AuthStatus.guest);

  const AuthSessionState.authenticated(AuthUser user)
    : this._(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final AuthUser? user;

  bool get isGuest => status == AuthStatus.guest;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}
