import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_models.dart';
import 'notifications_providers.dart';

const List<(String, NotificationCategory?)> _tabs =
    <(String, NotificationCategory?)>[
      ('All', null),
      ('Achievements', NotificationCategory.achievement),
      ('Missions', NotificationCategory.mission),
    ];

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tab = 0;
  bool _marking = false;

  Future<void> _markAllRead() async {
    setState(() => _marking = true);
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      ref.invalidate(notificationsProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.value?.unread ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (unread > 0)
            TextButton(
              onPressed: _marking ? null : _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.when(
        skipLoadingOnRefresh: true,
        data: (NotificationList? data) {
          if (data == null) {
            return const SignInRequiredView(
              icon: Icons.notifications_rounded,
              title: 'Stay in the loop',
              message:
                  'Sign in to get updates on achievements, missions and '
                  'replies.',
            );
          }
          return _content(data);
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
      ),
    );
  }

  Widget _content(NotificationList data) {
    final filter = _tabs[_tab].$2;
    final items = filter == null
        ? data.items
        : data.items
              .where((AppNotification n) => n.category == filter)
              .toList(growable: false);

    return Column(
      children: <Widget>[
        PillTabs(
          labels: <String>[for (final t in _tabs) t.$1],
          selectedIndex: _tab,
          onChanged: (int i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const <Widget>[
                      MessageView(
                        icon: Icons.notifications_off_outlined,
                        message: "You're all caught up.",
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) =>
                        _NotificationTile(item: items[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, color) = switch (item.category) {
      NotificationCategory.achievement => (
        Icons.emoji_events_rounded,
        AppColors.gold,
      ),
      NotificationCategory.mission => (Icons.flag_rounded, AppColors.success),
      NotificationCategory.streak => (
        Icons.local_fire_department_rounded,
        AppColors.orange,
      ),
      NotificationCategory.social => (Icons.forum_rounded, AppColors.blue),
      NotificationCategory.other => (
        Icons.notifications_rounded,
        AppColors.purple,
      ),
    };
    final message = item.message ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isUnread ? AppColors.surfaceAlt : AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (message.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  formatTimeAgo(item.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (item.isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, left: 8),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
