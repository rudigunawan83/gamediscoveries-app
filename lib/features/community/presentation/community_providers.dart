import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_repository.dart';
import '../domain/community_models.dart';

final communityHomeProvider = FutureProvider.autoDispose<CommunityHome>((
  Ref ref,
) {
  return ref.watch(communityRepositoryProvider).getHome();
});

final communityFeedProvider = FutureProvider.autoDispose<CommunityFeedPage>((
  Ref ref,
) {
  return ref.watch(communityRepositoryProvider).getFeed(limit: 30);
});
