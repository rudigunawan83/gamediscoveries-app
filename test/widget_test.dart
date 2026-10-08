import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/app/app.dart';
import 'package:gamediscoveries_mobile/core/network/models/paged_result.dart';
import 'package:gamediscoveries_mobile/core/storage/local_preferences.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/discovery/domain/models/home_discoveries.dart';
import 'package:gamediscoveries_mobile/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:gamediscoveries_mobile/shared/models/game_summary.dart';
import 'package:gamediscoveries_mobile/shared/widgets/brand_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthSessionController extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async {
    return const AuthSessionState.guest();
  }
}

const HomeDiscoveries _emptyHome = HomeDiscoveries(
  featured: <GameSummary>[],
  trending: <GameSummary>[],
  latest: <GameSummary>[],
  popular: <GameSummary>[],
  mobile: <GameSummary>[],
  multiplayer: <GameSummary>[],
  hotGames: <GameSummary>[],
  bestGames: <GameSummary>[],
  mostPlayed: <GameSummary>[],
  exclusiveGames: <GameSummary>[],
);

Future<void> _pumpApp(WidgetTester tester, SharedPreferences prefs) {
  return tester.pumpWidget(
    ProviderScope(
      retry: (int retryCount, Object error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authSessionControllerProvider.overrideWith(
          _FakeAuthSessionController.new,
        ),
        homeDiscoveriesProvider.overrideWith((Ref ref) async => _emptyHome),
        forYouProvider.overrideWith((Ref ref) async => <GameSummary>[]),
        gameListProvider(mobileReadyShelfQuery).overrideWith(
          (Ref ref) async => const PagedResult<GameSummary>(
            items: <GameSummary>[],
            page: 1,
            pageSize: 12,
            total: 0,
            totalPages: 0,
          ),
        ),
      ],
      child: const GameDiscoveriesApp(),
    ),
  );
}

void main() {
  testWidgets('first launch goes splash -> onboarding -> home on skip', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await _pumpApp(tester, prefs);

    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.text('Discoveries'), findsOneWidget);
    expect(find.text('Discover. Play. Progress.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(prefs.getBool('onboarding.done'), isTrue);
    expect(find.text('Hi, Player 👋'), findsOneWidget);
    expect(find.text('No games to show yet. Check back soon.'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('returning user skips onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding.done': true,
    });
    final prefs = await SharedPreferences.getInstance();
    await _pumpApp(tester, prefs);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsNothing);
    expect(find.text('Hi, Player 👋'), findsOneWidget);
  });
}
