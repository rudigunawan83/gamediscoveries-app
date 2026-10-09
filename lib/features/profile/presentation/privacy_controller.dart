import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/privacy_repository.dart';
import '../domain/privacy_settings.dart';

class PrivacyController extends AsyncNotifier<PrivacySettings> {
  @override
  Future<PrivacySettings> build() {
    return ref.watch(privacyRepositoryProvider).getPrivacy();
  }

  /// Optimistic: flips the switch immediately and rolls back on failure.
  Future<void> set(PrivacyOption option, bool value) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData<PrivacySettings>(current.copyWith(option, value));
    try {
      await ref.read(privacyRepositoryProvider).update(option, value);
    } catch (_) {
      state = AsyncData<PrivacySettings>(current);
      rethrow;
    }
  }
}

final privacyControllerProvider =
    AsyncNotifierProvider.autoDispose<PrivacyController, PrivacySettings>(
      PrivacyController.new,
    );
