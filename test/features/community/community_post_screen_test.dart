import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/app/router/app_routes.dart';
import 'package:gamediscoveries_mobile/core/storage/local_preferences.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/community/data/community_repository.dart';
import 'package:gamediscoveries_mobile/features/community/domain/community_models.dart';
import 'package:gamediscoveries_mobile/features/community/presentation/community_post_screen.dart';
import 'package:gamediscoveries_mobile/features/community/presentation/community_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const CommunityUser _me = CommunityUser(id: 'me', username: 'rudi');
const CommunityUser _ayu = CommunityUser(
  id: 'u2',
  username: 'ayu',
  displayName: 'Ayu',
);

class _SignedIn extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.authenticated(
        AuthUser(
          id: 'me',
          email: 'me@example.com',
          displayName: 'Rudi',
          roles: <String>['Player'],
        ),
      );
}

class _Guest extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async => const AuthSessionState.guest();
}

class _FakeRepository implements CommunityRepository {
  final List<CommunityComment> comments = <CommunityComment>[
    CommunityComment(
      id: 'c1',
      author: _ayu,
      content: 'Great tips!',
      replies: <CommunityComment>[
        CommunityComment(
          id: 'c2',
          parentId: 'c1',
          author: _me,
          content: 'Thanks Ayu',
        ),
      ],
    ),
  ];
  final List<(String, String?)> created = <(String, String?)>[];
  final List<String> deleted = <String>[];
  int likes = 0;

  @override
  Future<CommunityPost> getPost(String id) async => CommunityPost(
    id: id,
    postId: id,
    type: 'discussion',
    author: _ayu,
    title: 'Best puzzle games?',
    content: 'Share your favourite puzzle games here.',
    reactionCount: 4,
    commentCount: 2,
    viewCount: 10,
  );

  @override
  Future<List<CommunityComment>> getComments(String postId) async =>
      List<CommunityComment>.of(comments);

  @override
  Future<void> createComment(
    String postId, {
    required String content,
    String? parentId,
  }) async {
    created.add((content, parentId));
    comments.add(
      CommunityComment(
        id: 'new${created.length}',
        author: _me,
        content: content,
      ),
    );
  }

  @override
  Future<void> deleteComment(String commentId) async => deleted.add(commentId);

  @override
  Future<void> likePost(String postId) async => likes++;

  @override
  Future<void> unlikePost(String postId) async => likes--;

  final List<(CommunityPostSort, String?, String?)> listCalls =
      <(CommunityPostSort, String?, String?)>[];
  final List<String> deletedPosts = <String>[];

  @override
  Future<CommunityPostPage> listPosts({
    CommunityPostSort sort = CommunityPostSort.latest,
    String? search,
    String? cursor,
    int limit = 20,
  }) async {
    listCalls.add((sort, search, cursor));
    final items = <CommunityPost>[
      CommunityPost.fromPostJson(const <String, dynamic>{
        'id': 'p1',
        'type': 'game_share',
        'title': 'This game is amazing!',
        'content': 'Space Runner is super fun.',
        'reactionCount': 124,
        'commentCount': 28,
        'author': <String, dynamic>{
          'id': 'u2',
          'username': 'ayu',
          'displayName': 'Ayu',
          'level': 28,
        },
        'game': <String, dynamic>{
          'id': 'g1',
          'slug': 'space-runner',
          'title': 'Space Runner',
          'categories': <String>['Arcade', 'Action'],
        },
      }),
      CommunityPost.fromPostJson(const <String, dynamic>{
        'id': 'p2',
        'type': 'discussion',
        'title': 'My first post',
        'content': 'Hello everyone',
        'reactionCount': 3,
        'commentCount': 0,
        'author': <String, dynamic>{'id': 'me', 'username': 'rudi'},
      }),
    ];
    final q = search ?? '';
    return CommunityPostPage(
      items: items
          .where((CommunityPost p) => p.title.toLowerCase().contains(q))
          .toList(),
    );
  }

  @override
  Future<void> deletePost(String postId) async => deletedPosts.add(postId);

  @override
  Future<void> reportPost(String postId, {required String reason}) async {}

  @override
  Future<CommunityFeedPage> getFeed({String? cursor, int limit = 20}) async =>
      const CommunityFeedPage(items: <CommunityPost>[]);

  @override
  Future<CommunityHome> getHome() async =>
      const CommunityHome(trendingDiscussions: <CommunityPost>[]);

  @override
  Future<void> createPost({
    required String type,
    required String title,
    required String content,
    String? gameId,
  }) async {}
}

Widget _app(
  _FakeRepository repository, {
  bool signedIn = true,
  String initialLocation = '/community/posts/p1',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.community,
        builder: (BuildContext c, GoRouterState s) => const CommunityScreen(),
      ),
      GoRoute(
        path: AppRoutes.communitySaved,
        builder: (BuildContext c, GoRouterState s) =>
            const CommunitySavedScreen(),
      ),
      GoRoute(
        path: '/game/:slug',
        builder: (BuildContext c, GoRouterState s) =>
            Scaffold(body: Text('route:game:${s.pathParameters['slug']}')),
      ),
      GoRoute(
        path: '/community/posts/:id',
        builder: (BuildContext c, GoRouterState s) =>
            CommunityPostScreen(postId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext c, GoRouterState s) =>
            const Scaffold(body: Text('route:login')),
      ),
    ],
  );

  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(
        signedIn ? _SignedIn.new : _Guest.new,
      ),
      communityRepositoryProvider.overrideWithValue(repository),
      sharedPreferencesProvider.overrideWithValue(_prefs),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

late SharedPreferences _prefs;

/// 360x800 logical, so whole post cards and comment threads are built.
void _usePhoneView(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('shows the full post with threaded comments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(_FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Best puzzle games?'), findsOneWidget);
    expect(
      find.text('Share your favourite puzzle games here.'),
      findsOneWidget,
    );
    expect(find.text('Comments (2)'), findsOneWidget);
    expect(find.text('Great tips!'), findsOneWidget);
    expect(find.text('Thanks Ayu'), findsOneWidget);
    // Only my own comment can be deleted; replies cannot be replied to.
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
  });

  testWidgets('posts a comment and a reply', (WidgetTester tester) async {
    _usePhoneView(tester);
    final repository = _FakeRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Try Baba Is You');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    expect(repository.created.single, ('Try Baba Is You', null));
    expect(find.text('Try Baba Is You'), findsOneWidget);
    expect(find.text('Comments (3)'), findsOneWidget);

    await tester.tap(find.text('Reply').first);
    await tester.pump();
    expect(find.text('Replying to Ayu'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Agreed');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    expect(repository.created.last, ('Agreed', 'c1'));
    expect(find.text('Replying to Ayu'), findsNothing);
  });

  testWidgets('deletes my comment after confirming', (
    WidgetTester tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
    await tester.pumpAndSettle();

    expect(repository.deleted, <String>['c2']);
    expect(find.text('Comment deleted.'), findsOneWidget);
  });

  testWidgets('likes the post optimistically', (WidgetTester tester) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    expect(repository.likes, 1);
    expect(find.text('5'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('guests read comments but are asked to sign in to comment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(_FakeRepository(), signedIn: false));
    await tester.pumpAndSettle();

    expect(find.text('Great tips!'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Reply'), findsNothing);
    expect(find.text('Sign in to join the conversation.'), findsOneWidget);
  });

  group('community list', () {
    Future<_FakeRepository> pumpList(WidgetTester tester) async {
      _usePhoneView(tester);
      final repository = _FakeRepository();
      await tester.pumpWidget(
        _app(repository, initialLocation: AppRoutes.community),
      );
      await tester.pumpAndSettle();
      return repository;
    }

    testWidgets('shows post cards with level, section and game banner', (
      WidgetTester tester,
    ) async {
      final repository = await pumpList(tester);

      expect(find.text('This game is amazing!'), findsOneWidget);
      expect(find.text('Lv 28'), findsOneWidget);
      expect(find.text('in Game Shares'), findsOneWidget);
      expect(find.text('SPACE RUNNER'), findsOneWidget);
      expect(find.text('Arcade'), findsOneWidget);
      expect(find.text('124'), findsOneWidget);
      expect(find.text('Like'), findsNWidgets(2));
      expect(repository.listCalls.single.$1, CommunityPostSort.latest);

      await tester.tap(find.text('Trending'));
      await tester.pumpAndSettle();
      expect(repository.listCalls.last.$1, CommunityPostSort.trending);
      await tester.tap(find.text('Most Liked'));
      await tester.pumpAndSettle();
      expect(repository.listCalls.last.$1, CommunityPostSort.mostLiked);
    });

    testWidgets('opens the post detail and the game from a card', (
      WidgetTester tester,
    ) async {
      await pumpList(tester);

      await tester.tap(find.text('SPACE RUNNER'));
      await tester.pumpAndSettle();
      expect(find.text('route:game:space-runner'), findsOneWidget);

      GoRouter.of(tester.element(find.text('route:game:space-runner'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('This game is amazing!'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityPostScreen), findsOneWidget);
    });

    testWidgets('searches posts', (WidgetTester tester) async {
      final repository = await pumpList(tester);

      await tester.tap(find.byTooltip('Search posts'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'first');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(repository.listCalls.last.$2, 'first');
      expect(find.text('My first post'), findsOneWidget);
      expect(find.text('This game is amazing!'), findsNothing);
    });

    testWidgets('likes a post optimistically', (WidgetTester tester) async {
      final repository = await pumpList(tester);

      await tester.tap(find.text('Like').first);
      await tester.pumpAndSettle();

      expect(repository.likes, 1);
      expect(find.text('125'), findsOneWidget);
      expect(find.text('Liked'), findsOneWidget);
    });

    testWidgets('bookmarks a post and lists it under Saved', (
      WidgetTester tester,
    ) async {
      await pumpList(tester);

      await tester.tap(find.byTooltip('Save post').first);
      await tester.pumpAndSettle();
      expect(find.text('Saved to your posts.'), findsOneWidget);
      expect(_prefs.getStringList('community.savedPosts'), hasLength(1));

      await tester.tap(find.byTooltip('Saved posts'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunitySavedScreen), findsOneWidget);
      expect(find.text('This game is amazing!'), findsOneWidget);
      expect(find.text('Like'), findsNothing);
    });

    testWidgets('owner deletes a post, others can report', (
      WidgetTester tester,
    ) async {
      final repository = await pumpList(tester);

      await tester.tap(find.byTooltip('More options').first);
      await tester.pumpAndSettle();
      expect(find.text('Report post'), findsOneWidget);
      expect(find.text('Delete post'), findsNothing);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete post'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repository.deletedPosts, <String>['p2']);
      expect(find.text('Post deleted.'), findsOneWidget);
    });
  });
}
