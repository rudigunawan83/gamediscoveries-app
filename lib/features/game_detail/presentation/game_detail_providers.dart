import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_detail_repository.dart';
import '../domain/game_detail.dart';

final gameDetailProvider = FutureProvider.autoDispose
    .family<GameDetail, String>((Ref ref, String slug) {
      return ref.watch(gameDetailRepositoryProvider).getBySlug(slug);
    });

final gameReviewsProvider = FutureProvider.autoDispose
    .family<ReviewSummary, String>((Ref ref, String slug) {
      return ref.watch(gameDetailRepositoryProvider).getReviewSummary(slug);
    });
