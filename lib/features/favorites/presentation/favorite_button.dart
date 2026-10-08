import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
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
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
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

  try {
    final result = await ref.read(favoriteIdsProvider.notifier).toggle(gameId);
    if (result == FavoriteToggleResult.signInRequired) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Sign in to save your favorite games.'),
          action: SnackBarAction(
            label: 'Sign In',
            onPressed: () => router.push(AppRoutes.login),
          ),
        ),
      );
    }
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(friendlyErrorMessage(error))),
    );
  }
}
