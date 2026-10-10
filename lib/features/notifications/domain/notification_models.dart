import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

enum NotificationCategory { achievement, mission, streak, social, other }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    this.message,
    this.actorUsername,
    this.entityType,
    this.entityId,
    this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      message: json['message'] as String?,
      actorUsername: json['actorUsername'] as String?,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      createdAt: parseDate(json['createdAt']),
      readAt: parseDate(json['readAt']),
    );
  }

  final String id;
  final String type;
  final String? message;
  final String? actorUsername;

  /// `post`, `comment`, `user` or `achievement`; [entityId] is its id.
  final String? entityType;
  final String? entityId;
  final DateTime? createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  NotificationCategory get category {
    final t = type.toLowerCase();
    if (t.contains('achievement')) return NotificationCategory.achievement;
    if (t.contains('mission') || t.contains('challenge')) {
      return NotificationCategory.mission;
    }
    if (t.contains('streak')) return NotificationCategory.streak;
    if (t.contains('comment') ||
        t.contains('reply') ||
        t.contains('reaction') ||
        t.contains('follow') ||
        t.contains('mention')) {
      return NotificationCategory.social;
    }
    return NotificationCategory.other;
  }

  String get title {
    final words = type
        .replaceAll(RegExp(r'[_\-.]'), ' ')
        .toLowerCase()
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .map((String w) => w[0].toUpperCase() + w.substring(1));
    final label = words.join(' ');
    return label.isEmpty ? 'Notification' : label;
  }
}

class NotificationList {
  const NotificationList({required this.items, required this.unread});

  factory NotificationList.fromJson(Map<String, dynamic> json) {
    return NotificationList(
      items: parseJsonList(json['items'], AppNotification.fromJson),
      unread: parseInt(json['unread']),
    );
  }

  final List<AppNotification> items;
  final int unread;
}
