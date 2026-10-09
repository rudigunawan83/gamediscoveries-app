import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/utils/json_parsing.dart';
import '../domain/community_models.dart';

class CommunityRepository {
  CommunityRepository(this._api);

  final ApiClient _api;

  Future<CommunityHome> getHome() {
    return _api.get<CommunityHome>(
      '/api/v1/community/home',
      parser: (Object? json) =>
          CommunityHome.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<CommunityFeedPage> getFeed({String? cursor, int limit = 20}) {
    return _api.get<CommunityFeedPage>(
      '/api/v1/community/feed',
      queryParameters: <String, dynamic>{'limit': limit, 'cursor': ?cursor},
      parser: (Object? json) =>
          CommunityFeedPage.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<void> createPost({
    required String type,
    required String title,
    required String content,
    String? gameId,
  }) {
    return _api.postAction(
      '/api/v1/community/posts',
      body: <String, dynamic>{
        'type': type,
        'title': title,
        'content': content,
        'gameId': ?gameId,
      },
    );
  }

  /// [cursor] is the opaque `nextCursor` from the previous page.
  Future<CommunityPostPage> listPosts({
    CommunityPostSort sort = CommunityPostSort.latest,
    String? search,
    String? cursor,
    int limit = 20,
  }) {
    final query = search?.trim();
    return _api.get<CommunityPostPage>(
      '/api/v1/community/posts',
      queryParameters: <String, dynamic>{
        'sort': sort.apiValue,
        'limit': limit,
        if (query != null && query.isNotEmpty) 'q': query,
        'cursor': ?cursor,
      },
      parser: (Object? json) =>
          CommunityPostPage.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<void> deletePost(String postId) {
    return _api.deleteAction(
      '/api/v1/community/posts/${Uri.encodeComponent(postId)}',
    );
  }

  /// [reason] must be one of the API's report reasons (`spam`, ...).
  Future<void> reportPost(String postId, {required String reason}) {
    return _api.postAction(
      '/api/v1/community/reports',
      body: <String, dynamic>{
        'targetType': 'post',
        'targetId': postId,
        'reason': reason,
      },
    );
  }

  Future<CommunityPost> getPost(String id) {
    return _api.get<CommunityPost>(
      '/api/v1/community/posts/${Uri.encodeComponent(id)}',
      parser: (Object? json) =>
          CommunityPost.fromPostJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<List<CommunityComment>> getComments(String postId) {
    return _api.get<List<CommunityComment>>(
      '/api/v1/community/posts/${Uri.encodeComponent(postId)}/comments',
      parser: (Object? json) => parseJsonList(json, CommunityComment.fromJson),
    );
  }

  /// [parentId] replies to a top-level comment; the API allows one level.
  Future<void> createComment(
    String postId, {
    required String content,
    String? parentId,
  }) {
    return _api.postAction(
      '/api/v1/community/posts/${Uri.encodeComponent(postId)}/comments',
      body: <String, dynamic>{'content': content, 'parentId': ?parentId},
    );
  }

  Future<void> deleteComment(String commentId) {
    return _api.deleteAction(
      '/api/v1/community/comments/${Uri.encodeComponent(commentId)}',
    );
  }

  Future<void> likePost(String postId) {
    return _api.postAction(
      '/api/v1/community/post/${Uri.encodeComponent(postId)}/reactions',
      body: const <String, dynamic>{'reaction': 'like'},
    );
  }

  Future<void> unlikePost(String postId) {
    return _api.deleteAction(
      '/api/v1/community/post/${Uri.encodeComponent(postId)}/reactions',
    );
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>((Ref ref) {
  return CommunityRepository(ref.watch(apiClientProvider));
});
