import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/achievements_repository.dart';
import '../domain/achievement_models.dart';

/// `null` means the visitor is a guest.
final myAchievementsProvider = FutureProvider<AchievementList?>((
  Ref ref,
) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  return ref.watch(achievementsRepositoryProvider).getMyAchievements();
});
