import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/progress_repository.dart';
import '../domain/progress_models.dart';

/// `null` means the visitor is a guest.
final myProgressProvider = FutureProvider<UserProgress?>((Ref ref) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  return ref.watch(progressRepositoryProvider).getMyProgress();
});

final recentXpProvider = FutureProvider.autoDispose<List<XpTransaction>>((
  Ref ref,
) async {
  if (!await ref.watch(isSignedInProvider.future)) return <XpTransaction>[];
  return ref.watch(progressRepositoryProvider).getRecentXp();
});
