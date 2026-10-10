import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/game_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/my_reviews_repository.dart';
import '../domain/my_review.dart';
import 'my_reviews_providers.dart';

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(myReviewsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileMyReviews)),
      body: reviews.when(
        skipLoadingOnRefresh: true,
        data: (List<MyReview>? items) {
          if (items == null) {
            return SignInRequiredView(
              icon: Icons.rate_review_rounded,
              title: l10n.reviewsSignInTitle,
              message: l10n.reviewsSignInMessage,
            );
          }
          if (items.isEmpty) {
            return MessageView(
              icon: Icons.rate_review_outlined,
              title: l10n.reviewsEmptyTitle,
              message: l10n.reviewsEmptyMessage,
              actionLabel: l10n.commonFindGame,
              onAction: () => context.go(AppRoutes.discover),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myReviewsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) =>
                  _ReviewCard(review: items[index]),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(myReviewsProvider),
        ),
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.review});

  static const double _thumbWidth = 72;

  final MyReview review;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.reviewsDeleteTitle),
        content: Text(l10n.reviewsDeleteMessage(review.gameTitle)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.commonDelete,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    try {
      await ref.read(myReviewsRepositoryProvider).deleteReview(review.id);
      ref.invalidate(myReviewsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.reviewsDeleted)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final edited = review.updatedAt ?? review.createdAt;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: review.gameSlug.isEmpty
            ? null
            : () => context.push(AppRoutes.game(review.gameSlug)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: _thumbWidth,
                      height: _thumbWidth * 0.75,
                      child: GameImage(
                        url: review.gameThumbnailUrl,
                        logicalWidth: _thumbWidth,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          review.gameTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Semantics(
                          label: l10n.reviewsRatedSemantics(review.rating),
                          excludeSemantics: true,
                          child: Row(
                            children: <Widget>[
                              for (var i = 0; i < 5; i++)
                                Icon(
                                  i < review.rating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 16,
                                  color: AppColors.gold,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.reviewsDeleteTooltip,
                    onPressed: () => _delete(context, ref),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (review.content.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    review.content,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Text(
                    formatTimeAgo(l10n, edited),
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (review.isHidden) ...<Widget>[
                    const SizedBox(width: 8),
                    Text(
                      l10n.reviewsHidden,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
