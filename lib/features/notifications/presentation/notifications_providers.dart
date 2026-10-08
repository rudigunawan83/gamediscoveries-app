import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_models.dart';

/// `null` means the visitor is a guest.
final notificationsProvider = FutureProvider<NotificationList?>((
  Ref ref,
) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});

final unreadNotificationsProvider = Provider<int>((Ref ref) {
  return ref.watch(notificationsProvider).value?.unread ?? 0;
});
