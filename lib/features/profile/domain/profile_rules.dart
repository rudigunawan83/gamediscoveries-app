final RegExp _usernamePattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

enum ProfileField { displayName, username }

class ProfileDraft {
  const ProfileDraft({required this.displayName, required this.username});

  final String displayName;
  final String username;

  String get normalizedName => displayName.trim();
  String get normalizedUsername => username.trim().toLowerCase();
}

bool profileUnchanged(
  ProfileDraft draft, {
  required String currentName,
  required String? currentUsername,
}) {
  return draft.normalizedName == currentName.trim() &&
      draft.normalizedUsername == (currentUsername ?? '').trim().toLowerCase();
}

/// Fields whose new value fails the same rules as `PUT /api/v1/users/me/profile`.
List<ProfileField> profileFieldErrors(
  ProfileDraft draft, {
  required String currentName,
  required String? currentUsername,
}) {
  final savedName = currentName.trim();
  final savedUsername = (currentUsername ?? '').trim().toLowerCase();
  final errors = <ProfileField>[];
  final name = draft.normalizedName;
  if (name != savedName &&
      (name.length < 2 ||
          name.length > 40 ||
          name.runes.any((int rune) => rune < 0x20 || rune == 0x7f))) {
    errors.add(ProfileField.displayName);
  }
  final handle = draft.normalizedUsername;
  if (handle != savedUsername &&
      (handle.length < 3 ||
          handle.length > 30 ||
          !_usernamePattern.hasMatch(handle))) {
    errors.add(ProfileField.username);
  }
  return errors;
}
