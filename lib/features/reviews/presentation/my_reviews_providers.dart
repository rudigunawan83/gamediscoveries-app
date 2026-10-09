import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/my_reviews_repository.dart';
import '../domain/my_review.dart';

/// `null` means the visitor is a guest.
final myReviewsProvider = FutureProvider.autoDispose<List<MyReview>?>((
  Ref ref,
) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  return ref.watch(myReviewsRepositoryProvider).getMyReviews();
});
