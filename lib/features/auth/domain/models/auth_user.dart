class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.roles,
    this.username,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      roles: ((json['roles'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic role) => role.toString())
          .toList(growable: false),
    );
  }

  final String id;
  final String email;
  final String displayName;

  /// Public handle; older API builds omit it.
  final String? username;
  final String? avatarUrl;
  final List<String> roles;

  bool get isAuthenticated => id.isNotEmpty;
}
