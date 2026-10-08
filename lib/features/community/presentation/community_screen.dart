import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/community_repository.dart';
import '../domain/community_models.dart';
import 'community_providers.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int _tab = 0;

  Future<void> _openComposer() async {
    final signedIn = await ref.read(isSignedInProvider.future);
    if (!mounted) return;

    if (!signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign in to post in the community.'),
          action: SnackBarAction(
            label: 'Sign In',
            onPressed: () => context.push(AppRoutes.login),
          ),
        ),
      );
      return;
    }

    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (BuildContext context) => const _ComposerSheet(),
    );
    if (posted ?? false) {
      ref
        ..invalidate(communityFeedProvider)
        ..invalidate(communityHomeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New post',
        onPressed: _openComposer,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: Column(
        children: <Widget>[
          PillTabs(
            labels: const <String>['Latest', 'Trending', 'Most Liked'],
            selectedIndex: _tab,
            onChanged: (int i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _tab == 0
                ? const _LatestFeed()
                : _Discussions(mostLiked: _tab == 2),
          ),
        ],
      ),
    );
  }
}

class _LatestFeed extends ConsumerWidget {
  const _LatestFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(communityFeedProvider);

    return feed.when(
      skipLoadingOnRefresh: true,
      data: (CommunityFeedPage page) => _PostList(
        posts: page.items,
        onRefresh: () => ref.refresh(communityFeedProvider.future),
      ),
      loading: () => const LoadingView(),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(communityFeedProvider),
      ),
    );
  }
}

class _Discussions extends ConsumerWidget {
  const _Discussions({required this.mostLiked});

  final bool mostLiked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(communityHomeProvider);

    return home.when(
      skipLoadingOnRefresh: true,
      data: (CommunityHome data) {
        final posts = List<CommunityPost>.of(data.trendingDiscussions);
        if (mostLiked) {
          posts.sort(
            (CommunityPost a, CommunityPost b) =>
                b.reactionCount.compareTo(a.reactionCount),
          );
        }
        return _PostList(
          posts: posts,
          onRefresh: () => ref.refresh(communityHomeProvider.future),
        );
      },
      loading: () => const LoadingView(),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(communityHomeProvider),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.posts, required this.onRefresh});

  final List<CommunityPost> posts;
  final Future<Object?> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const MessageView(
        icon: Icons.forum_outlined,
        title: 'Nothing here yet',
        message: 'Start the conversation with the + button.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        itemCount: posts.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) =>
            _PostCard(post: posts[index]),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final game = post.game;
    final label = post.typeLabel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GdAvatar(
                name: post.author.name,
                imageUrl: post.author.avatarUrl,
                size: 38,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      formatTimeAgo(post.createdAt),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (label.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (post.title.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              post.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (post.content.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (game != null && game.slug.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(
                Icons.favorite_rounded,
                size: 18,
                color: AppColors.danger,
              ),
              const SizedBox(width: 4),
              Text(formatCompact(post.reactionCount)),
              const SizedBox(width: 16),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(formatCompact(post.commentCount)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposerSheet extends ConsumerStatefulWidget {
  const _ComposerSheet();

  @override
  ConsumerState<_ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends ConsumerState<_ComposerSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  String _type = 'discussion';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      setState(() => _error = 'Title and message are required.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(communityRepositoryProvider)
          .createPost(
            type: _type,
            title: _title.text.trim(),
            content: _content.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = friendlyErrorMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'New Post',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          PillTabs(
            padding: EdgeInsets.zero,
            labels: const <String>['Discussion', 'Question'],
            selectedIndex: _type == 'discussion' ? 0 : 1,
            onChanged: (int i) =>
                setState(() => _type = i == 0 ? 'discussion' : 'question'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            maxLength: 120,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _content,
            minLines: 3,
            maxLines: 6,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Share something with the community...',
            ),
          ),
          if (error != null) ...<Widget>[
            Text(error, style: const TextStyle(color: AppColors.danger)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }
}
