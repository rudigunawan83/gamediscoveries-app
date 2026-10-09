import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/community_repository.dart';
import '../domain/community_models.dart';
import 'community_providers.dart';
import 'community_widgets.dart';

/// Must match the API's `Community:CommentMaxLength`.
const int _commentMaxLength = 1500;

class CommunityPostScreen extends ConsumerStatefulWidget {
  const CommunityPostScreen({required this.postId, super.key});

  final String postId;

  @override
  ConsumerState<CommunityPostScreen> createState() =>
      _CommunityPostScreenState();
}

class _CommunityPostScreenState extends ConsumerState<CommunityPostScreen> {
  final TextEditingController _comment = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  CommunityComment? _replyTo;
  bool _sending = false;

  /// Optimistic copy after a like toggle; `null` means use the fetched post.
  CommunityPost? _localPost;
  bool _liking = false;

  @override
  void dispose() {
    _comment.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _refreshLists() => ref.invalidate(communityPostsProvider);

  Future<void> _toggleLike(CommunityPost post, bool signedIn) async {
    if (!signedIn) {
      showCommunitySignInPrompt(context, 'Sign in to like posts.');
      return;
    }
    if (_liking) return;

    final liked = post.likedByViewer;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _liking = true;
      _localPost = post.withReaction(liked ? null : 'like');
    });
    try {
      final repository = ref.read(communityRepositoryProvider);
      if (liked) {
        await repository.unlikePost(widget.postId);
      } else {
        await repository.likePost(widget.postId);
      }
      _refreshLists();
    } catch (error) {
      if (mounted) setState(() => _localPost = post);
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  void _startReply(CommunityComment comment) {
    setState(() => _replyTo = comment);
    _commentFocus.requestFocus();
  }

  Future<void> _send() async {
    final content = _comment.text.trim();
    if (content.isEmpty || _sending) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(communityRepositoryProvider)
          .createComment(
            widget.postId,
            content: content,
            parentId: _replyTo?.id,
          );
      _comment.clear();
      _commentFocus.unfocus();
      if (mounted) setState(() => _replyTo = null);
      ref.invalidate(communityCommentsProvider(widget.postId));
      _refreshLists();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(CommunityComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete comment?'),
        content: const Text('Your comment will be removed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(communityRepositoryProvider).deleteComment(comment.id);
      if (_replyTo?.id == comment.id) setState(() => _replyTo = null);
      ref.invalidate(communityCommentsProvider(widget.postId));
      _refreshLists();
      messenger.showSnackBar(const SnackBar(content: Text('Comment deleted.')));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(communityPostProvider(widget.postId));
    final commentsAsync = ref.watch(communityCommentsProvider(widget.postId));
    final viewerId = ref.watch(authSessionControllerProvider).value?.user?.id;
    final signedIn = viewerId != null;
    final loaded = _localPost ?? postAsync.value;
    final saved = ref.watch(
      savedCommunityPostsProvider.select(
        (List<CommunityPost> posts) =>
            posts.any((CommunityPost p) => p.postId == widget.postId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: <Widget>[
          if (loaded != null) ...<Widget>[
            IconButton(
              tooltip: saved ? 'Remove from saved' : 'Save post',
              color: saved ? AppColors.gold : null,
              onPressed: () => toggleSavedCommunityPost(context, ref, loaded),
              icon: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Share post',
              onPressed: () => shareCommunityPost(loaded),
              icon: const Icon(Icons.ios_share_rounded),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: postAsync.when(
        skipLoadingOnRefresh: true,
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(communityPostProvider(widget.postId)),
        ),
        data: (CommunityPost fetched) {
          final post = _localPost ?? fetched;
          final comments = commentsAsync.value;
          final commentCount = comments == null
              ? post.commentCount
              : comments.fold<int>(
                  0,
                  (int sum, CommunityComment c) => sum + 1 + c.replies.length,
                );

          return Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    setState(() => _localPost = null);
                    ref.invalidate(communityCommentsProvider(widget.postId));
                    return ref.refresh(
                      communityPostProvider(widget.postId).future,
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: <Widget>[
                      _PostBody(
                        post: post,
                        commentCount: commentCount,
                        onLike: () => _toggleLike(post, signedIn),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.line, height: 1),
                      const SizedBox(height: 16),
                      Text(
                        'Comments ($commentCount)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...commentsAsync.when(
                        skipLoadingOnRefresh: true,
                        loading: () => const <Widget>[
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ],
                        error: (Object error, StackTrace stackTrace) =>
                            <Widget>[
                              _InlineError(
                                error: error,
                                onRetry: () => ref.invalidate(
                                  communityCommentsProvider(widget.postId),
                                ),
                              ),
                            ],
                        data: (List<CommunityComment> items) => items.isEmpty
                            ? const <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    'No comments yet. Start the conversation!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ]
                            : <Widget>[
                                for (final comment in items)
                                  _CommentThread(
                                    comment: comment,
                                    viewerId: viewerId,
                                    onReply: signedIn ? _startReply : null,
                                    onDelete: _delete,
                                  ),
                              ],
                      ),
                    ],
                  ),
                ),
              ),
              _Composer(
                signedIn: signedIn,
                controller: _comment,
                focusNode: _commentFocus,
                replyTo: _replyTo,
                sending: _sending,
                onCancelReply: () => setState(() => _replyTo = null),
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({
    required this.post,
    required this.commentCount,
    required this.onLike,
  });

  final CommunityPost post;
  final int commentCount;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = post.game;
    final liked = post.likedByViewer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CommunityAuthorHeader(post: post, avatarSize: 48),
        if (post.title.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            post.title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
        if (post.content.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          SelectableText(
            post.content,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
        if (game != null && game.slug.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          ActionChip(
            avatar: const Icon(
              Icons.sports_esports_rounded,
              size: 16,
              color: AppColors.gold,
            ),
            label: Text(game.title),
            onPressed: () => context.push(AppRoutes.game(game.slug)),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Semantics(
              button: true,
              toggled: liked,
              label: liked ? 'Unlike post' : 'Like post',
              excludeSemantics: true,
              child: Material(
                color: liked
                    ? AppColors.danger.withValues(alpha: 0.15)
                    : AppColors.surface,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: liked ? AppColors.danger : AppColors.line,
                  ),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: onLike,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatCompact(post.reactionCount),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(formatCompact(commentCount)),
            if (post.viewCount > 0) ...<Widget>[
              const SizedBox(width: 16),
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(formatCompact(post.viewCount)),
            ],
          ],
        ),
      ],
    );
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    required this.viewerId,
    required this.onReply,
    required this.onDelete,
  });

  final CommunityComment comment;
  final String? viewerId;
  final ValueChanged<CommunityComment>? onReply;
  final ValueChanged<CommunityComment> onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CommentTile(
            comment: comment,
            isMine: comment.author.id == viewerId,
            onReply: onReply,
            onDelete: onDelete,
          ),
          if (comment.replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 18, top: 8),
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.line, width: 2),
                ),
              ),
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final reply in comment.replies)
                    _CommentTile(
                      comment: reply,
                      isMine: reply.author.id == viewerId,
                      onDelete: onDelete,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isMine,
    required this.onDelete,
    this.onReply,
  });

  final CommunityComment comment;
  final bool isMine;

  /// Only top-level comments accept replies.
  final ValueChanged<CommunityComment>? onReply;
  final ValueChanged<CommunityComment> onDelete;

  @override
  Widget build(BuildContext context) {
    final reply = onReply;
    const actionStyle = ButtonStyle(
      visualDensity: VisualDensity.compact,
      padding: WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 8),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GdAvatar(
            name: comment.author.name,
            imageUrl: comment.author.avatarUrl,
            size: 34,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: isMine ? 'You' : comment.author.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: '  ${formatTimeAgo(comment.createdAt)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  comment.content,
                  style: const TextStyle(height: 1.4),
                ),
                Row(
                  children: <Widget>[
                    if (reply != null)
                      TextButton(
                        style: actionStyle,
                        onPressed: () => reply(comment),
                        child: const Text('Reply'),
                      ),
                    if (isMine)
                      TextButton(
                        style: actionStyle,
                        onPressed: () => onDelete(comment),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          Text(
            friendlyErrorMessage(error),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.signedIn,
    required this.controller,
    required this.focusNode,
    required this.replyTo,
    required this.sending,
    required this.onCancelReply,
    required this.onSend,
  });

  final bool signedIn;
  final TextEditingController controller;
  final FocusNode focusNode;
  final CommunityComment? replyTo;
  final bool sending;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final reply = replyTo;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: !signedIn
              ? Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Sign in to join the conversation.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Sign In'),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (reply != null)
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.reply_rounded,
                            size: 16,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Replying to ${reply.author.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cancel reply',
                            visualDensity: VisualDensity.compact,
                            onPressed: onCancelReply,
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: !sending,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: _commentMaxLength,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: reply == null
                                  ? 'Write a comment...'
                                  : 'Write a reply...',
                              counterText: '',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ListenableBuilder(
                          listenable: controller,
                          builder: (BuildContext context, Widget? child) =>
                              IconButton(
                                tooltip: 'Send comment',
                                color: AppColors.gold,
                                onPressed:
                                    sending || controller.text.trim().isEmpty
                                    ? null
                                    : onSend,
                                icon: sending
                                    ? const SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
