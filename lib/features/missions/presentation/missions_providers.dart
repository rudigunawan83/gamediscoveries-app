import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/missions_repository.dart';
import '../domain/mission_models.dart';

/// `null` means the visitor is a guest.
final myMissionsProvider = FutureProvider<MyMissions?>((Ref ref) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  return ref.watch(missionsRepositoryProvider).getMyMissions();
});
