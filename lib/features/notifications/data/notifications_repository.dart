import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<NotificationList> getNotifications() {
    return _api.get<NotificationList>(
      '/api/v1/community/notifications',
      parser: (Object? json) =>
          NotificationList.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<void> markAllRead() {
    return _api.postAction(
      '/api/v1/community/notifications/read',
      body: const <String, dynamic>{'notificationId': null},
    );
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  Ref ref,
) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});
