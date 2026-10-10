import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../shared/widgets/gold_tab.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/community_repository.dart';
import '../domain/community_models.dart';
import 'community_providers.dart';
import 'community_widgets.dart';

const double _maxContentWidth = 640;

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  CommunityPostSort _sort = CommunityPostSort.latest;
  bool _searching = false;
  String _search = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _search = text.trim());
    });
  }

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searching = false;
      _search = '';
    });
  }

  Future<void> _openComposer() async {
    final signedIn = await ref.read(isSignedInProvider.future);
    if (!mounted) return;

    if (!signedIn) {
      showCommunitySignInPrompt(context, context.l10n.communitySignInToPost);
      return;
    }

    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (BuildContext context) => const _ComposerSheet(),
    );
    if (posted ?? false) ref.invalidate(communityPostsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final CommunityPostQuery query = (sort: _sort, search: _search);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: (String text) {
                  _debounce?.cancel();
                  setState(() => _search = text.trim());
                },
                decoration: InputDecoration(
                  hintText: l10n.communitySearchPosts,
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              )
            : const _Title(),
        actions: <Widget>[
          if (_searching)
            IconButton(
              tooltip: l10n.communityCloseSearch,
              onPressed: _closeSearch,
              icon: const Icon(Icons.close_rounded),
            )
          else ...<Widget>[
            IconButton(
              tooltip: l10n.communitySavedPostsTooltip,
              onPressed: () => context.push(AppRoutes.communitySaved),
              icon: const Icon(Icons.bookmarks_outlined),
            ),
            _CircleIconButton(
              tooltip: l10n.communitySearchPosts,
              icon: Icons.search_rounded,
              onPressed: () => setState(() => _searching = true),
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.communityNewPostTooltip,
        onPressed: _openComposer,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: _Centered(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                spacing: 8,
                children: <Widget>[
                  for (final sort in CommunityPostSort.values)
                    Expanded(
                      child: GoldTab(
                        label: communitySortLabel(l10n, sort),
                        icon: _sortIcon(sort),
                        selected: sort == _sort,
                        onTap: () => setState(() => _sort = sort),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _PostFeed(
                key: ValueKey<CommunityPostQuery>(query),
                query: query,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget? _sortIcon(CommunityPostSort sort) => switch (sort) {
    CommunityPostSort.latest => null,
    CommunityPostSort.trending => const ExcludeSemantics(
      child: Text('🔥', style: TextStyle(fontSize: 17)),
    ),
    CommunityPostSort.mostLiked => const ExcludeSemantics(
      child: Text('👑', style: TextStyle(fontSize: 17)),
    ),
  };
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: AppColors.goldGradient.createShader,
          child: const Icon(Icons.sports_esports_rounded, size: 34),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            context.l10n.communityTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.line),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}

/// Caps content to a readable width on tablets.
class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: child,
      ),
    );
  }
}

class _PostFeed extends ConsumerStatefulWidget {
  const _PostFeed({required this.query, super.key});

  final CommunityPostQuery query;

  @override
  ConsumerState<_PostFeed> createState() => _PostFeedState();
}

class _PostFeedState extends ConsumerState<_PostFeed> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scroll.position.extentAfter < 600) {
      ref.read(communityPostsProvider(widget.query).notifier).loadMore();
    }
  }

  Future<void> _like(CommunityPost post) async {
    final signedIn = ref.read(isSignedInProvider).value ?? false;
    if (!signedIn) {
      showCommunitySignInPrompt(context, context.l10n.communitySignInToLike);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(communityPostsProvider(widget.query).notifier)
          .toggleLike(post);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityPostsProvider(widget.query));
    final saved = ref.watch(savedCommunityPostsProvider);
    final savedIds = <String?>{for (final p in saved) p.postId};

    return posts.when(
      skipLoadingOnRefresh: true,
      loading: () => const LoadingView(),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(communityPostsProvider(widget.query)),
      ),
      data: (CommunityPostList list) {
        if (list.items.isEmpty) {
          final search = widget.query.search;
          final l10n = context.l10n;
          return search.isEmpty
              ? MessageView(
                  icon: Icons.forum_outlined,
                  title: l10n.communityEmptyTitle,
                  message: l10n.communityEmptyMessage,
                )
              : MessageView(
                  icon: Icons.search_off_rounded,
                  title: l10n.communityNoResultsTitle,
                  message: l10n.communityNoResultsMessage(search),
                );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(communityPostsProvider(widget.query).future),
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: list.items.length + (list.isLoadingMore ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              if (index >= list.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final post = list.items[index];
              return CommunityPostCard(
                post: post,
                saved: savedIds.contains(post.postId),
                onLike: () => _like(post),
                onToggleSave: () =>
                    toggleSavedCommunityPost(context, ref, post),
                onShare: () => shareCommunityPost(context.l10n, post),
                onMore: () => showCommunityPostMenu(context, ref, post),
              );
            },
          ),
        );
      },
    );
  }
}

/// Bookmarked posts, stored on this device.
class CommunitySavedScreen extends ConsumerWidget {
  const CommunitySavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedCommunityPostsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communitySavedPostsTitle)),
      body: saved.isEmpty
          ? MessageView(
              icon: Icons.bookmark_border_rounded,
              title: l10n.communityNoSavedTitle,
              message: l10n.communityNoSavedMessage,
            )
          : _Centered(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: saved.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  final post = saved[index];
                  return CommunityPostCard(
                    post: post,
                    saved: true,
                    onToggleSave: () =>
                        toggleSavedCommunityPost(context, ref, post),
                    onShare: () => shareCommunityPost(l10n, post),
                    onMore: () => showCommunityPostMenu(context, ref, post),
                  );
                },
              ),
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
  bool _incomplete = false;
  Object? _error;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      setState(() {
        _incomplete = true;
        _error = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _incomplete = false;
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
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = _error;
    final error = _incomplete
        ? l10n.communityComposerRequired
        : (failure == null ? null : friendlyErrorMessage(l10n, failure));

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
            l10n.communityNewPostTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          PillTabs(
            padding: EdgeInsets.zero,
            labels: <String>[
              l10n.communityTypeDiscussion,
              l10n.communityTypeQuestion,
            ],
            selectedIndex: _type == 'discussion' ? 0 : 1,
            onChanged: (int i) =>
                setState(() => _type = i == 0 ? 'discussion' : 'question'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            maxLength: 120,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l10n.communityTitleHint),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _content,
            minLines: 3,
            maxLines: 6,
            maxLength: 2000,
            decoration: InputDecoration(hintText: l10n.communityContentHint),
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
                : Text(l10n.communityPublish),
          ),
        ],
      ),
    );
  }
}
