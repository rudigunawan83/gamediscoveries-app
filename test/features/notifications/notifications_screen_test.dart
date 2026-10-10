import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/app/router/app_routes.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/notifications/data/notifications_repository.dart';
import 'package:gamediscoveries_mobile/features/notifications/domain/notification_models.dart';
import 'package:gamediscoveries_mobile/features/notifications/presentation/notifications_screen.dart';

import '../../helpers/localized_app.dart';
import 'package:go_router/go_router.dart';

class _SignedIn extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.authenticated(
        AuthUser(
          id: 'u1',
          email: 'a@b.c',
          displayName: 'Rudi',
          roles: <String>[],
        ),
      );
}

class _FakeRepo implements NotificationsRepository {
  _FakeRepo(this.items);

  List<AppNotification> items;
  final List<String> marked = <String>[];

  @override
  Future<NotificationList> getNotifications() async => NotificationList(
    items: List<AppNotification>.of(items),
    unread: items.where((AppNotification n) => n.isUnread).length,
  );

  @override
  Future<void> markRead(String notificationId) async {
    marked.add(notificationId);
    items = <AppNotification>[
      for (final n in items)
        n.id == notificationId
            ? AppNotification(
                id: n.id,
                type: n.type,
                message: n.message,
                entityType: n.entityType,
                entityId: n.entityId,
                createdAt: n.createdAt,
                readAt: DateTime.utc(2026, 10, 9),
              )
            : n,
    ];
  }

  @override
  Future<void> markAllRead() async {}
}

Widget _app(_FakeRepo repo, {Locale locale = const Locale('en')}) {
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => const NotificationsScreen()),
      GoRoute(
        path: '/community/posts/:id',
        builder: (_, GoRouterState state) =>
            Text('post ${state.pathParameters['id']}'),
      ),
    ],
  );
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(_SignedIn.new),
      notificationsRepositoryProvider.overrideWithValue(repo),
    ],
    child: localizedRouterApp(router, locale: locale),
  );
}

void main() {
  testWidgets('tapping an unread notification marks it read', (
    WidgetTester tester,
  ) async {
    final repo = _FakeRepo(<AppNotification>[
      const AppNotification(
        id: 'n1',
        type: 'user_followed',
        message: 'rudi started following you',
        entityType: 'user',
        entityId: 'u2',
      ),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsOneWidget);

    await tester.tap(find.text('rudi started following you'));
    await tester.pumpAndSettle();

    expect(repo.marked, <String>['n1']);
    expect(find.text('Mark all read'), findsNothing);
    expect(find.text('rudi started following you'), findsOneWidget);
  });

  testWidgets('tapping a post notification opens the post', (
    WidgetTester tester,
  ) async {
    final repo = _FakeRepo(<AppNotification>[
      const AppNotification(
        id: 'n2',
        type: 'comment_on_post',
        message: 'ana commented on your post',
        entityType: 'post',
        entityId: 'p9',
      ),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ana commented on your post'));
    await tester.pumpAndSettle();

    expect(repo.marked, <String>['n2']);
    expect(find.text('post p9'), findsOneWidget);
    expect(AppRoutes.communityPost('p9'), '/community/posts/p9');
  });

  final titleItems = <AppNotification>[
    const AppNotification(id: 'n1', type: 'user_followed', message: 'm1'),
    const AppNotification(id: 'n2', type: 'season_reset', message: 'm2'),
    const AppNotification(id: 'n3', type: '', message: 'm3'),
  ];

  testWidgets('translates known notification types', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(_FakeRepo(titleItems)));
    await tester.pumpAndSettle();

    expect(find.text('New Follower'), findsOneWidget);
    expect(find.text('Season Reset'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
  });

  testWidgets('shows Indonesian notification titles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(_FakeRepo(titleItems), locale: const Locale('id')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pengikut Baru'), findsOneWidget);
    expect(find.text('Season Reset'), findsOneWidget);
    expect(find.text('Notifikasi'), findsWidgets);
    expect(find.text('m1'), findsOneWidget);
  });
}
