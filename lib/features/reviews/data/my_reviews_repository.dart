import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/my_review.dart';

class MyReviewsRepository {
  MyReviewsRepository(this._api);

  final ApiClient _api;

  Future<List<MyReview>> getMyReviews() {
    return _api.get<List<MyReview>>(
      '/api/v1/users/me/reviews',
      parser: MyReview.listFrom,
    );
  }

  Future<void> deleteReview(String id) {
    return _api.deleteAction('/api/v1/reviews/${Uri.encodeComponent(id)}');
  }
}

final myReviewsRepositoryProvider = Provider<MyReviewsRepository>((Ref ref) {
  return MyReviewsRepository(ref.watch(apiClientProvider));
});
