import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/app/router/app_routes.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/features/achievements/domain/achievement_models.dart';
import 'package:gamediscoveries_mobile/features/achievements/presentation/achievements_providers.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/profile/data/avatar_repository.dart';
import 'package:gamediscoveries_mobile/features/profile/presentation/avatar_controller.dart';
import 'package:gamediscoveries_mobile/features/profile/presentation/profile_screen.dart';
import 'package:gamediscoveries_mobile/features/progress/domain/progress_models.dart';
import 'package:gamediscoveries_mobile/features/progress/presentation/progress_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

const AuthUser _user = AuthUser(
  id: 'u1',
  email: 'rudi@example.com',
  displayName: 'Rudi',
  username: 'rudi_gamer',
  roles: <String>['Player'],
);

const AuthUser _userWithoutHandle = AuthUser(
  id: 'u1',
  email: 'rudi@example.com',
  displayName: 'Rudi',
  roles: <String>['Player'],
);

class _SignedInAuthController extends AuthSessionController {
  _SignedInAuthController(this.user);

  final AuthUser user;

  @override
  Future<AuthSessionState> build() async =>
      AuthSessionState.authenticated(user);
}

class _GuestAuthController extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async => const AuthSessionState.guest();
}

class _FakePicker extends ImagePicker {
  _FakePicker(this.file);

  final XFile? file;
  ImageSource? requestedSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    requestedSource = source;
    return file;
  }
}

class _FakeAvatarRepository implements AvatarRepository {
  String? uploadedName;
  int uploadedBytes = 0;

  @override
  Future<AuthUser> upload(List<int> bytes, {required String fileName}) async {
    uploadedName = fileName;
    uploadedBytes = bytes.length;
    return const AuthUser(
      id: 'u1',
      email: 'rudi@example.com',
      displayName: 'Rudi',
      username: 'rudi_gamer',
      roles: <String>['Player'],
      avatarUrl: 'https://api.example.com/media/avatars/u1/new.jpg',
    );
  }

  @override
  Future<AuthUser> remove() async => _user;
}

const UserProgress _progress = UserProgress(
  userName: 'Rudi',
  level: LevelInfo(
    level: 12,
    title: 'Explorer',
    totalXp: 1200,
    currentLevelXp: 18450,
    nextLevelXp: 20000,
    progressPercentage: 92.25,
    isMaxLevel: false,
  ),
  stats: ProgressStats(
    totalGameSessions: 48,
    uniqueGamesPlayed: 31,
    favorites: 5,
    currentStreak: 3,
    longestStreak: 9,
  ),
);

const List<String> _mainLabels = <String>[
  'My Favorites',
  'Play History',
  'My Reviews',
  'Account Settings',
  'Help & Support',
];

Widget _app({
  bool signedIn = true,
  AuthUser user = _user,
  Future<UserProgress?> Function()? loadProgress,
  ImagePicker? picker,
  AvatarRepository? avatarRepository,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.profile,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext c, GoRouterState s) => const ProfileScreen(),
      ),
      for (final path in <String>[
        AppRoutes.favorites,
        AppRoutes.history,
        AppRoutes.accountSettings,
        AppRoutes.help,
        AppRoutes.myReviews,
        AppRoutes.progress,
        AppRoutes.achievements,
        AppRoutes.leaderboard,
        AppRoutes.community,
        AppRoutes.notifications,
        AppRoutes.login,
        AppRoutes.register,
      ])
        GoRoute(
          path: path,
          builder: (BuildContext c, GoRouterState s) =>
              Scaffold(appBar: AppBar(), body: Text('route:$path')),
        ),
    ],
  );

  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(
        signedIn
            ? () => _SignedInAuthController(user)
            : _GuestAuthController.new,
      ),
      myProgressProvider.overrideWith(
        (Ref ref) => (loadProgress ?? () async => _progress)(),
      ),
      myAchievementsProvider.overrideWith(
        (Ref ref) async => const AchievementList(
          items: <Achievement>[],
          totalDefinitions: 40,
          userUnlocked: 24,
        ),
      ),
      if (picker != null) imagePickerProvider.overrideWithValue(picker),
      if (avatarRepository != null)
        avatarRepositoryProvider.overrideWithValue(avatarRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Finder _semanticsLabel(String label) => find.byWidgetPredicate(
  (Widget w) => w is Semantics && w.properties.label == label,
);

Future<void> _scrollTo(WidgetTester tester, String label) async {
  final finder = find.text(label);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows backend identity, level, stats and menu in order', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byTooltip('Account Settings'), findsOneWidget);
    expect(find.text('Rudi'), findsOneWidget);
    expect(find.text('@rudi_gamer'), findsOneWidget);
    expect(find.text('Level 12'), findsOneWidget);
    expect(find.text('18,450 / 20,000 XP'), findsOneWidget);
    expect(find.text('Games'), findsNWidgets(2));
    expect(find.text('48'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('1.2K'), findsOneWidget);
    expect(find.text('Achievements'), findsWidgets);
    expect(find.text('Points'), findsOneWidget);

    await _scrollTo(tester, 'Help & Support');
    final tops = <double>[
      for (final label in _mainLabels) tester.getTopLeft(find.text(label)).dy,
    ];
    for (var i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]), reason: _mainLabels[i]);
    }
    expect(find.text('Soon'), findsNothing);
  });

  testWidgets('menu items open their existing routes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Account Settings'));
    await tester.pumpAndSettle();
    expect(find.text('route:${AppRoutes.accountSettings}'), findsOneWidget);

    final routes = <String, String>{
      'My Favorites': AppRoutes.favorites,
      'Play History': AppRoutes.history,
      'My Reviews': AppRoutes.myReviews,
      'Account Settings': AppRoutes.accountSettings,
      'Help & Support': AppRoutes.help,
    };
    for (final MapEntry<String, String> entry in routes.entries) {
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _scrollTo(tester, entry.key);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text('route:${entry.value}'), findsOneWidget);
    }
  });

  testWidgets('falls back to email when the API has no username', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(user: _userWithoutHandle));
    await tester.pumpAndSettle();

    expect(find.text('rudi@example.com'), findsOneWidget);
    expect(find.textContaining('@rudi_gamer'), findsNothing);
  });

  testWidgets('progress failure shows retry and keeps the menu usable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        loadProgress: () async =>
            throw const ApiException(message: 'boom', statusCode: 503),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Our servers are having trouble. Please try again later.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Rudi'), findsOneWidget);
    await _scrollTo(tester, 'My Favorites');
    expect(find.text('My Favorites'), findsOneWidget);
  });

  testWidgets('guest sees sign-in actions and the same menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(signedIn: false));
    await tester.pumpAndSettle();

    expect(find.text('Guest Player'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    for (final label in _mainLabels) {
      await _scrollTo(tester, label);
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('uploads a photo picked from the gallery', (
    WidgetTester tester,
  ) async {
    final picker = _FakePicker(
      XFile.fromData(Uint8List(16), path: 'me.png', mimeType: 'image/png'),
    );
    final repository = _FakeAvatarRepository();
    await tester.pumpWidget(_app(picker: picker, avatarRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(_semanticsLabel('Change avatar'));
    await tester.pumpAndSettle();
    expect(find.text('Remove photo'), findsNothing);

    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(picker.requestedSource, ImageSource.gallery);
    expect(repository.uploadedName, 'me.png');
    expect(repository.uploadedBytes, 16);
    expect(find.text('Avatar updated.'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(
      container.read(authSessionControllerProvider).value?.user?.avatarUrl,
      'https://api.example.com/media/avatars/u1/new.jpg',
    );
  });

  testWidgets('cancelling the picker uploads nothing', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAvatarRepository();
    await tester.pumpWidget(
      _app(picker: _FakePicker(null), avatarRepository: repository),
    );
    await tester.pumpAndSettle();

    await tester.tap(_semanticsLabel('Change avatar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();

    expect(repository.uploadedName, isNull);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('guests cannot edit the avatar', (WidgetTester tester) async {
    await tester.pumpWidget(_app(signedIn: false));
    await tester.pumpAndSettle();

    expect(_semanticsLabel('Change avatar'), findsNothing);
  });

  testWidgets('small phone with large text does not overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _scrollTo(tester, 'Help & Support');

    expect(tester.takeException(), isNull);
  });
}
