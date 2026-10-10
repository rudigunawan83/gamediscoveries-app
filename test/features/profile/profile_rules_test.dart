import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/features/profile/domain/profile_rules.dart';

void main() {
  const currentName = 'Rudi';
  const currentUsername = 'rudi_gamer';

  test('ignores casing and surrounding spaces', () {
    const draft = ProfileDraft(displayName: ' Rudi ', username: 'RUDI_GAMER');
    expect(
      profileUnchanged(
        draft,
        currentName: currentName,
        currentUsername: currentUsername,
      ),
      isTrue,
    );
    expect(
      profileFieldErrors(
        draft,
        currentName: currentName,
        currentUsername: currentUsername,
      ),
      isEmpty,
    );
  });

  test('rejects a new name or username that breaks the rules', () {
    expect(
      profileFieldErrors(
        const ProfileDraft(displayName: 'A', username: 'Rudi Gamer'),
        currentName: currentName,
        currentUsername: currentUsername,
      ),
      <ProfileField>[ProfileField.displayName, ProfileField.username],
    );
  });

  test('keeps a legacy username when only the name changes', () {
    expect(
      profileFieldErrors(
        const ProfileDraft(displayName: 'Rudi Baru', username: 'rudi_gamer'),
        currentName: currentName,
        currentUsername: currentUsername,
      ),
      isEmpty,
    );
  });
}
