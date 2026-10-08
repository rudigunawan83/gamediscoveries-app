import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
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
}

final communityRepositoryProvider = Provider<CommunityRepository>((Ref ref) {
  return CommunityRepository(ref.watch(apiClientProvider));
});
