import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/reviews/data/my_reviews_repository.dart';
import 'package:gamediscoveries_mobile/features/reviews/domain/my_review.dart';
import 'package:gamediscoveries_mobile/features/reviews/presentation/my_reviews_screen.dart';

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

class _FakeRepo implements MyReviewsRepository {
  _FakeRepo(this.items);

  final List<MyReview> items;
  final List<String> deleted = <String>[];

  @override
  Future<List<MyReview>> getMyReviews() async => List<MyReview>.of(items);

  @override
  Future<void> deleteReview(String id) async {
    deleted.add(id);
    items.removeWhere((MyReview r) => r.id == id);
  }
}

Widget _app(_FakeRepo repo) {
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(_SignedIn.new),
      myReviewsRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: MyReviewsScreen()),
  );
}

void main() {
  test('parses the /users/me/reviews payload', () {
    final reviews = MyReview.listFrom(<Object?>[
      <String, dynamic>{
        'id': 'r1',
        'rating': 4,
        'content': 'Fun!',
        'status': 'hidden',
        'createdAt': '2026-10-01T10:00:00+00:00',
        'updatedAt': '2026-10-02T10:00:00+00:00',
        'game': <String, dynamic>{
          'id': 'g1',
          'slug': 'space-run',
          'title': 'Space Run',
          'thumbnailUrl': null,
        },
      },
    ]);

    expect(reviews.single.rating, 4);
    expect(reviews.single.gameSlug, 'space-run');
    expect(reviews.single.isHidden, isTrue);
    expect(reviews.single.updatedAt, DateTime.utc(2026, 10, 2, 10));
  });

  testWidgets('lists reviews and deletes after confirmation', (
    WidgetTester tester,
  ) async {
    final repo = _FakeRepo(<MyReview>[
      const MyReview(
        id: 'r1',
        rating: 5,
        content: 'Loved it',
        status: 'published',
        gameSlug: 'space-run',
        gameTitle: 'Space Run',
      ),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Space Run'), findsOneWidget);
    expect(find.text('Loved it'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w is Semantics && w.properties.label == 'Rated 5 out of 5',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Delete review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repo.deleted, <String>['r1']);
    expect(find.text('No reviews yet'), findsOneWidget);
  });
}
