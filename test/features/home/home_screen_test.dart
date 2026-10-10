import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/core/network/models/paged_result.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/discovery/domain/models/home_discoveries.dart';
import 'package:gamediscoveries_mobile/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:gamediscoveries_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:gamediscoveries_mobile/shared/models/game_summary.dart';

import '../../helpers/localized_app.dart';

class _GuestAuthController extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async => const AuthSessionState.guest();
}

GameSummary _game(String title) {
  return GameSummary(
    id: title,
    slug: title.toLowerCase(),
    title: title,
    category: 'Arcade',
    mobileReady: true,
  );
}

HomeDiscoveries _home({List<GameSummary> trending = const <GameSummary>[]}) {
  return HomeDiscoveries(
    featured: <GameSummary>[_game('Featured Hero')],
    trending: trending,
    latest: const <GameSummary>[],
    popular: const <GameSummary>[],
    mobile: const <GameSummary>[],
    multiplayer: const <GameSummary>[],
    hotGames: const <GameSummary>[],
    bestGames: const <GameSummary>[],
    mostPlayed: const <GameSummary>[],
    exclusiveGames: const <GameSummary>[],
  );
}

Widget _app({required Future<HomeDiscoveries> Function() loadHome}) {
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(_GuestAuthController.new),
      homeDiscoveriesProvider.overrideWith((Ref ref) => loadHome()),
      forYouProvider.overrideWith((Ref ref) async => <GameSummary>[]),
      gameListProvider(mobileReadyShelfQuery).overrideWith(
        (Ref ref) async => PagedResult<GameSummary>(
          items: <GameSummary>[_game('Touch Hero')],
          page: 1,
          pageSize: 12,
          total: 1,
          totalPages: 1,
        ),
      ),
    ],
    child: localizedApp(home: const HomeScreen()),
  );
}

void main() {
  testWidgets('renders guest header, missions banner and shelves', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        loadHome: () async => _home(trending: <GameSummary>[_game('Hot One')]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hi, Player 👋'), findsOneWidget);
    expect(find.text('Sign in to earn XP & level up'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w is Semantics &&
            (w.properties.label?.startsWith('New Adventures') ?? false),
      ),
      findsOneWidget,
    );
    expect(find.text('Daily Missions'), findsNothing);
    expect(find.text('Recommended For You'), findsOneWidget);
    expect(find.text('Featured Hero'), findsOneWidget);
    expect(find.text('Trending Now'), findsOneWidget);
    expect(find.text('Hot One'), findsNWidgets(2));
    expect(find.text('Made for Mobile'), findsOneWidget);
    expect(find.text('Touch Hero'), findsOneWidget);
    expect(find.text('Continue Playing'), findsNothing);
    expect(find.text('Popular'), findsNothing);
  });

  testWidgets('shows friendly error with retry when home fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        loadHome: () async =>
            throw const ApiException(message: 'boom', statusCode: 503),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Our servers are having trouble. Please try again later.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });
}
