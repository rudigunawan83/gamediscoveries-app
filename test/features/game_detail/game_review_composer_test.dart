import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/l10n/app_language.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';
import 'package:gamediscoveries_mobile/core/network/api_client.dart';
import 'package:gamediscoveries_mobile/core/storage/local_preferences.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/community/domain/community_models.dart';
import 'package:gamediscoveries_mobile/features/game_detail/data/game_detail_repository.dart';
import 'package:gamediscoveries_mobile/features/game_detail/domain/game_detail.dart';
import 'package:gamediscoveries_mobile/features/game_detail/presentation/game_review_composer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedIn extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.authenticated(
        AuthUser(
          id: 'u1',
          email: 'rudi@example.com',
          displayName: 'Rudi',
          username: 'rudi',
          roles: <String>[],
        ),
      );
}

class _Guest extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async => const AuthSessionState.guest();
}

class _FakeReviews extends GameDetailRepository {
  _FakeReviews() : super(ApiClient(Dio()));

  int? rating;
  String? content;

  @override
  Future<GameReview> upsertReview(
    String slug, {
    required int rating,
    required String content,
  }) async {
    this.rating = rating;
    this.content = content;
    return GameReview(
      id: 'r1',
      rating: rating,
      content: content,
      author: const CommunityUser(id: 'u1', username: 'rudi'),
    );
  }
}

Future<Widget> _app({required bool signedIn, _FakeReviews? reviews}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authSessionControllerProvider.overrideWith(
        signedIn ? _SignedIn.new : _Guest.new,
      ),
      if (reviews != null)
        gameDetailRepositoryProvider.overrideWithValue(reviews),
    ],
    child: Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) =>
          MaterialApp(
            locale: ref.watch(appLanguageProvider).locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback:
                (List<Locale>? locales, Iterable<Locale> supported) =>
                    resolveSupportedLocale(locales, supported: supported),
            home: const Scaffold(
              body: GameReviewComposer(slug: 'asteroid-dodge'),
            ),
          ),
    ),
  );
}

void main() {
  testWidgets('asks guests to sign in', (WidgetTester tester) async {
    await tester.pumpWidget(await _app(signedIn: false));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to write a review.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('posts a rating and review when signed in', (
    WidgetTester tester,
  ) async {
    final reviews = _FakeReviews();
    await tester.pumpWidget(await _app(signedIn: true, reviews: reviews));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Fast and fun.');
    await tester.pump();
    await tester.tap(find.text('Submit review'));
    await tester.pumpAndSettle();

    expect(reviews.rating, 5);
    expect(reviews.content, 'Fast and fun.');
    expect(find.text('Review posted'), findsOneWidget);
  });
}
