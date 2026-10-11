import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../../reviews/presentation/my_reviews_providers.dart';
import '../data/game_detail_repository.dart';
import 'game_detail_providers.dart';

/// Star rating and text for `POST /api/v1/games/{slug}/reviews`.
class GameReviewComposer extends ConsumerStatefulWidget {
  const GameReviewComposer({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<GameReviewComposer> createState() => _GameReviewComposerState();
}

class _GameReviewComposerState extends ConsumerState<GameReviewComposer> {
  static const int _maxLength = 2000;

  final TextEditingController _content = TextEditingController();
  int _rating = 5;
  bool _saving = false;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _content.text.trim();
    if (text.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(gameDetailRepositoryProvider)
          .upsertReview(widget.slug, rating: _rating, content: text);
      _content.clear();
      ref.invalidate(gameReviewsProvider(widget.slug));
      ref.invalidate(myReviewsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.gameReviewSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(context.l10n, error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn =
        ref.watch(authSessionControllerProvider).value?.isAuthenticated == true;
    if (!signedIn) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => context.push(AppRoutes.login),
          child: Text(l10n.gameSignInToReview),
        ),
      );
    }

    final canSend = _content.text.trim().isNotEmpty && !_saving;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.gameYourRating,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Row(
            children: <Widget>[
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: l10n.gameReviewStars(star),
                  visualDensity: VisualDensity.compact,
                  onPressed: _saving
                      ? null
                      : () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.gold,
                  ),
                ),
            ],
          ),
          TextField(
            controller: _content,
            minLines: 3,
            maxLines: 5,
            maxLength: _maxLength,
            textCapitalization: TextCapitalization.sentences,
            enabled: !_saving,
            decoration: InputDecoration(
              hintText: l10n.gameReviewHint,
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: canSend ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.onGold,
              disabledBackgroundColor: AppColors.surfaceAlt,
              disabledForegroundColor: AppColors.textMuted,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              _saving ? l10n.gameSavingReview : l10n.gameSubmitReview,
            ),
          ),
        ],
      ),
    );
  }
}
