import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_preferences.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/community_repository.dart';
import '../domain/community_models.dart';

typedef CommunityPostQuery = ({CommunityPostSort sort, String search});

class CommunityPostList {
  const CommunityPostList({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<CommunityPost> items;
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  CommunityPostList copyWith({
    List<CommunityPost>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) {
    return CommunityPostList(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Paged posts for one tab (sort) and search term.
class CommunityPostsController extends AsyncNotifier<CommunityPostList> {
  CommunityPostsController(this.query);

  final CommunityPostQuery query;
  final Set<String> _pendingLikes = <String>{};

  @override
  Future<CommunityPostList> build() async {
    // Re-fetch with the viewer's identity (viewerReaction) after sign-in/out.
    await ref.watch(isSignedInProvider.future);
    final page = await ref
        .watch(communityRepositoryProvider)
        .listPosts(sort: query.sort, search: query.search);
    return CommunityPostList(items: page.items, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        state.isLoading) {
      return;
    }

    state = AsyncData<CommunityPostList>(current.copyWith(isLoadingMore: true));
    final repository = ref.read(communityRepositoryProvider);
    try {
      final page = await repository.listPosts(
        sort: query.sort,
        search: query.search,
        cursor: current.nextCursor,
      );
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      final seen = latest.items.map((CommunityPost p) => p.id).toSet();
      state = AsyncData<CommunityPostList>(
        CommunityPostList(
          items: <CommunityPost>[
            ...latest.items,
            ...page.items.where((CommunityPost p) => !seen.contains(p.id)),
          ],
          nextCursor: page.nextCursor,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData<CommunityPostList>(
        latest.copyWith(isLoadingMore: false, clearCursor: true),
      );
    }
  }

  /// Optimistic; rolls back and rethrows when the API call fails.
  Future<void> toggleLike(CommunityPost post) async {
    final postId = post.postId;
    if (postId == null || !_pendingLikes.add(postId)) return;

    final liked = post.likedByViewer;
    final repository = ref.read(communityRepositoryProvider);
    _replace(post.withReaction(liked ? null : 'like'));
    try {
      if (liked) {
        await repository.unlikePost(postId);
      } else {
        await repository.likePost(postId);
      }
    } catch (_) {
      if (ref.mounted) _replace(post);
      rethrow;
    } finally {
      _pendingLikes.remove(postId);
    }
  }

  void remove(String postId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData<CommunityPostList>(
      current.copyWith(
        items: current.items
            .where((CommunityPost p) => p.postId != postId)
            .toList(),
      ),
    );
  }

  void _replace(CommunityPost post) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData<CommunityPostList>(
      current.copyWith(
        items: <CommunityPost>[
          for (final item in current.items) item.id == post.id ? post : item,
        ],
      ),
    );
  }
}

final communityPostsProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityPostsController, CommunityPostList, CommunityPostQuery>(
      CommunityPostsController.new,
    );

const int _maxSavedPosts = 100;

/// Bookmarks are kept on this device only; the API has no saved-posts store.
class SavedCommunityPostsController extends Notifier<List<CommunityPost>> {
  @override
  List<CommunityPost> build() {
    final saved = <CommunityPost>[];
    for (final raw in ref.watch(localPreferencesProvider).savedCommunityPosts) {
      try {
        final json = jsonDecode(raw);
        if (json is Map<String, dynamic>) {
          saved.add(CommunityPost.fromPostJson(json));
        }
      } on FormatException {
        // Skip corrupt entries.
      }
    }
    return saved;
  }

  bool isSaved(String? postId) =>
      postId != null && state.any((CommunityPost p) => p.postId == postId);

  Future<void> toggle(CommunityPost post) {
    final postId = post.postId;
    if (postId == null) return Future<void>.value();

    final others = state.where((CommunityPost p) => p.postId != postId);
    state = isSaved(postId)
        ? others.toList()
        : <CommunityPost>[post, ...others].take(_maxSavedPosts).toList();
    return ref
        .read(localPreferencesProvider)
        .setSavedCommunityPosts(
          state.map((CommunityPost p) => jsonEncode(p.toPostJson())).toList(),
        );
  }
}

final savedCommunityPostsProvider =
    NotifierProvider<SavedCommunityPostsController, List<CommunityPost>>(
      SavedCommunityPostsController.new,
    );

final communityPostProvider = FutureProvider.autoDispose
    .family<CommunityPost, String>((Ref ref, String id) async {
      // Re-fetch with the viewer's identity after sign-in/out.
      await ref.watch(isSignedInProvider.future);
      return ref.watch(communityRepositoryProvider).getPost(id);
    });

final communityCommentsProvider = FutureProvider.autoDispose
    .family<List<CommunityComment>, String>((Ref ref, String postId) async {
      // Re-fetch with the viewer's identity after sign-in/out.
      await ref.watch(isSignedInProvider.future);
      return ref.watch(communityRepositoryProvider).getComments(postId);
    });
