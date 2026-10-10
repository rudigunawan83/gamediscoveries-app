import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/community_repository.dart';
import '../domain/community_models.dart';
import 'community_providers.dart';

void showCommunitySignInPrompt(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: context.l10n.commonSignIn,
        onPressed: () => context.push(AppRoutes.login),
      ),
    ),
  );
}

Future<void> shareCommunityPost(AppLocalizations l10n, CommunityPost post) {
  final postId = post.postId;
  if (postId == null) return Future<void>.value();
  final title = post.title.isEmpty
      ? l10n.communityShareFallbackTitle
      : post.title;
  return SharePlus.instance.share(
    ShareParams(
      text: l10n.communityShareText(
        title,
        AppConfig.communityPostShareUrl(postId),
      ),
      subject: post.title,
    ),
  );
}

Future<void> toggleSavedCommunityPost(
  BuildContext context,
  WidgetRef ref,
  CommunityPost post,
) async {
  final notifier = ref.read(savedCommunityPostsProvider.notifier);
  final wasSaved = notifier.isSaved(post.postId);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  await notifier.toggle(post);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          wasSaved
              ? l10n.communityRemovedFromSaved
              : l10n.communitySavedToPosts,
        ),
      ),
    );
}

/// The section a post lives in, e.g. "Discussions".
String communitySectionLabel(AppLocalizations l10n, CommunityPost post) =>
    switch (post.type) {
      'discussion' => l10n.communitySectionDiscussions,
      'question' => l10n.communitySectionQuestions,
      'recommendation' => l10n.communitySectionRecommendations,
      'game_share' => l10n.communitySectionGameShares,
      'achievement_share' => l10n.communitySectionAchievements,
      _ => post.typeLabel,
    };

String communitySortLabel(AppLocalizations l10n, CommunityPostSort sort) =>
    switch (sort) {
      CommunityPostSort.latest => l10n.communitySortLatest,
      CommunityPostSort.trending => l10n.communitySortTrending,
      CommunityPostSort.mostLiked => l10n.communitySortMostLiked,
    };

enum _PostMenuAction { share, save, report, delete }

/// Report reason codes sent to the API, with their localized labels.
Map<String, String> _reportReasons(AppLocalizations l10n) => <String, String>{
  'spam': l10n.communityReportSpam,
  'harassment': l10n.communityReportHarassment,
  'misleading': l10n.communityReportMisleading,
  'other': l10n.communityReportOther,
};

/// Share / bookmark / report / delete sheet for a post.
Future<void> showCommunityPostMenu(
  BuildContext context,
  WidgetRef ref,
  CommunityPost post,
) async {
  final postId = post.postId;
  if (postId == null) return;
  final viewerId = ref.read(authSessionControllerProvider).value?.user?.id;
  final isMine = viewerId != null && viewerId == post.author.id;
  final saved = ref.read(savedCommunityPostsProvider.notifier).isSaved(postId);
  final l10n = context.l10n;

  final action = await showModalBottomSheet<_PostMenuAction>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (BuildContext context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: Text(l10n.communitySharePost),
            onTap: () => Navigator.of(context).pop(_PostMenuAction.share),
          ),
          ListTile(
            leading: Icon(
              saved
                  ? Icons.bookmark_remove_rounded
                  : Icons.bookmark_add_rounded,
            ),
            title: Text(
              saved ? l10n.communityRemoveFromSaved : l10n.communitySavePost,
            ),
            onTap: () => Navigator.of(context).pop(_PostMenuAction.save),
          ),
          if (!isMine)
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.communityReportPost),
              onTap: () => Navigator.of(context).pop(_PostMenuAction.report),
            ),
          if (isMine)
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: Text(
                l10n.communityDeletePost,
                style: const TextStyle(color: AppColors.danger),
              ),
              onTap: () => Navigator.of(context).pop(_PostMenuAction.delete),
            ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _PostMenuAction.share:
      await shareCommunityPost(l10n, post);
    case _PostMenuAction.save:
      await toggleSavedCommunityPost(context, ref, post);
    case _PostMenuAction.report:
      await _reportPost(context, ref, postId, signedIn: viewerId != null);
    case _PostMenuAction.delete:
      await _deletePost(context, ref, post);
  }
}

Future<void> _reportPost(
  BuildContext context,
  WidgetRef ref,
  String postId, {
  required bool signedIn,
}) async {
  final l10n = context.l10n;
  if (!signedIn) {
    showCommunitySignInPrompt(context, l10n.communitySignInToReport);
    return;
  }

  final reason = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.communityReportTitle),
      children: <Widget>[
        for (final entry in _reportReasons(l10n).entries)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(entry.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(entry.value),
            ),
          ),
      ],
    ),
  );
  if (reason == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(communityRepositoryProvider)
        .reportPost(postId, reason: reason);
    messenger.showSnackBar(SnackBar(content: Text(l10n.communityReportThanks)));
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
    );
  }
}

Future<void> _deletePost(
  BuildContext context,
  WidgetRef ref,
  CommunityPost post,
) async {
  final postId = post.postId;
  if (postId == null) return;
  final l10n = context.l10n;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.communityDeletePostTitle),
      content: Text(l10n.communityDeletePostMessage),
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
  if (!(confirmed ?? false) || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final saved = ref.read(savedCommunityPostsProvider.notifier);
  try {
    await ref.read(communityRepositoryProvider).deletePost(postId);
    if (saved.isSaved(postId)) await saved.toggle(post);
    ref.invalidate(communityPostsProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.communityPostDeleted)));
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
    );
  }
}

class CommunityLevelBadge extends StatelessWidget {
  const CommunityLevelBadge({required this.level, super.key});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold, width: 1.2),
      ),
      child: Text(
        context.l10n.commonLevelShort(level),
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Avatar, name, level, time and section ("in Discussions").
class CommunityAuthorHeader extends StatelessWidget {
  const CommunityAuthorHeader({
    required this.post,
    this.trailing,
    this.avatarSize = 46,
    super.key,
  });

  final CommunityPost post;
  final Widget? trailing;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final level = post.author.level;
    final l10n = context.l10n;
    final section = communitySectionLabel(l10n, post);
    final trail = trailing;
    const muted = TextStyle(color: AppColors.textMuted, fontSize: 13);

    return Row(
      children: <Widget>[
        GdAvatar(
          name: post.author.name,
          imageUrl: post.author.avatarUrl,
          size: avatarSize,
          ringColor: AppColors.gold,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (level != null) ...<Widget>[
                    const SizedBox(width: 8),
                    CommunityLevelBadge(level: level),
                  ],
                  if (post.createdAt != null)
                    Text(
                      '  •  ${formatTimeAgo(l10n, post.createdAt)}',
                      maxLines: 1,
                      style: muted,
                    ),
                ],
              ),
              if (section.isNotEmpty) ...<Widget>[
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.sports_esports_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        l10n.communityInSection(section),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        ?trail,
      ],
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    required this.post,
    required this.saved,
    required this.onToggleSave,
    required this.onShare,
    required this.onMore,
    this.onLike,
    super.key,
  });

  final CommunityPost post;
  final bool saved;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;
  final VoidCallback onMore;

  /// Hidden when `null` (e.g. offline bookmark snapshots).
  final VoidCallback? onLike;

  static const Set<String> _sideThumbTypes = <String>{'discussion', 'question'};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final postId = post.postId;
    final game = post.game;
    final hasGame = game != null && game.slug.isNotEmpty;
    final thumb = game?.thumbnailUrl ?? '';
    final sideThumb =
        hasGame && thumb.isNotEmpty && _sideThumbTypes.contains(post.type);
    final open = postId == null
        ? null
        : () => context.push(AppRoutes.communityPost(postId));
    final radius = BorderRadius.circular(20);

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (post.title.isNotEmpty)
          Text(
            post.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        if (post.content.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1C1B24), AppColors.card],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.07),
            blurRadius: 18,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CommunityAuthorHeader(
                  post: post,
                  trailing: IconButton(
                    tooltip: context.l10n.communityMoreOptions,
                    visualDensity: VisualDensity.compact,
                    onPressed: onMore,
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                if (sideThumb)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: texts),
                      const SizedBox(width: 12),
                      _SideThumb(game: game, imageUrl: thumb),
                    ],
                  )
                else
                  texts,
                if (hasGame && !sideThumb) ...<Widget>[
                  const SizedBox(height: 12),
                  _GameBanner(game: game),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.line),
                const SizedBox(height: 4),
                _ActionBar(
                  post: post,
                  saved: saved,
                  onComment: open,
                  onToggleSave: onToggleSave,
                  onShare: onShare,
                  onLike: onLike,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameBanner extends StatelessWidget {
  const _GameBanner({required this.game});

  final CommunityGame game;

  @override
  Widget build(BuildContext context) {
    final thumb = game.thumbnailUrl ?? '';
    final radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      label: context.l10n.communityOpenGame(game.title),
      child: Material(
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        color: AppColors.surfaceAlt,
        child: InkWell(
          onTap: () => context.push(AppRoutes.game(game.slug)),
          child: AspectRatio(
            aspectRatio: 16 / 7.5,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (thumb.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: thumb,
                    fit: BoxFit.cover,
                    errorWidget: (BuildContext c, String u, Object e) =>
                        const _BannerPlaceholder(),
                  )
                else
                  const _BannerPlaceholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xCC0B0B10), Color(0x000B0B10)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: 0.62,
                        child: Text(
                          game.title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            shadows: <Shadow>[
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              child: Row(
                                spacing: 6,
                                children: <Widget>[
                                  for (final (int i, String c)
                                      in game.categories.indexed)
                                    _CategoryChip(
                                      label: c,
                                      highlighted: i == 0,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.night.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.line),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF2A1B5C), Color(0xFF14163A)],
        ),
      ),
      child: Align(
        alignment: Alignment(0.7, 0),
        child: Icon(
          Icons.sports_esports_rounded,
          size: 56,
          color: Color(0x55FFFFFF),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.gold
            : AppColors.night.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: highlighted ? null : Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: highlighted ? AppColors.onGold : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SideThumb extends StatelessWidget {
  const _SideThumb({required this.game, required this.imageUrl});

  final CommunityGame game;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cacheSize = (96 * MediaQuery.devicePixelRatioOf(context)).round();

    return Semantics(
      button: true,
      label: context.l10n.communityOpenGame(game.title),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        color: AppColors.surfaceAlt,
        child: InkWell(
          onTap: () => context.push(AppRoutes.game(game.slug)),
          child: SizedBox.square(
            dimension: 96,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: cacheSize,
              errorWidget: (BuildContext c, String u, Object e) =>
                  const _BannerPlaceholder(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.post,
    required this.saved,
    required this.onComment,
    required this.onToggleSave,
    required this.onShare,
    required this.onLike,
  });

  final CommunityPost post;
  final bool saved;
  final VoidCallback? onComment;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    final like = onLike;
    final l10n = context.l10n;
    const countStyle = TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Semantics(
                  label: l10n.communityLikesSemantics(post.reactionCount),
                  excludeSemantics: true,
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.favorite_rounded,
                        size: 22,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatCompact(l10n, post.reactionCount),
                        style: countStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                TextButton.icon(
                  onPressed: onComment,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 21),
                  label: Text(
                    formatCompact(l10n, post.commentCount),
                    style: countStyle,
                  ),
                ),
                IconButton(
                  tooltip: saved
                      ? l10n.communityRemoveFromSaved
                      : l10n.communitySavePost,
                  onPressed: onToggleSave,
                  color: saved ? AppColors.gold : AppColors.textSecondary,
                  icon: Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
                IconButton(
                  tooltip: l10n.communitySharePost,
                  onPressed: onShare,
                  color: AppColors.textSecondary,
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
            ),
          ),
        ),
        if (like != null) _LikeButton(liked: post.likedByViewer, onTap: like),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.liked, required this.onTap});

  final bool liked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = liked ? AppColors.onGold : AppColors.gold;
    final l10n = context.l10n;

    return Semantics(
      button: true,
      toggled: liked,
      label: liked ? l10n.communityUnlikePost : l10n.communityLikePost,
      excludeSemantics: true,
      child: Material(
        color: liked ? AppColors.gold : AppColors.gold.withValues(alpha: 0.08),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.gold, width: 1.4),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    liked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_rounded,
                    size: 18,
                    color: foreground,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    liked ? l10n.communityLiked : l10n.communityLike,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
