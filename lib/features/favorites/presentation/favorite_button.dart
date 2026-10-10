import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
import 'library_providers.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({required this.gameId, this.size = 24, super.key});

  final String gameId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoriteIdsProvider).value?.contains(gameId) ?? false;

    return IconButton(
      tooltip: isFavorite
          ? context.l10n.favoritesRemove
          : context.l10n.favoritesAdd,
      onPressed: () => toggleFavorite(context, ref, gameId),
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: size,
        color: isFavorite ? AppColors.danger : AppColors.textSecondary,
      ),
    );
  }
}

Future<void> toggleFavorite(
  BuildContext context,
  WidgetRef ref,
  String gameId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final l10n = context.l10n;

  try {
    final result = await ref.read(favoriteIdsProvider.notifier).toggle(gameId);
    if (result == FavoriteToggleResult.signInRequired) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.favoritesSignInPrompt),
          action: SnackBarAction(
            label: l10n.commonSignIn,
            onPressed: () => router.push(AppRoutes.login),
          ),
        ),
      );
    }
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
    );
  }
}
