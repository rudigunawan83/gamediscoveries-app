import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/game_summary.dart';
import '../../data/repositories/discovery_repository.dart';
import '../../domain/models/game_list_query.dart';

const int _discoverPageSize = 20;

class DiscoverState {
  const DiscoverState({
    this.query = const GameListQuery(
      pageSize: _discoverPageSize,
      sort: GameSort.trending,
    ),
    this.items = const <GameSummary>[],
    this.hasMore = true,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  final GameListQuery query;
  final List<GameSummary> items;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  DiscoverState copyWith({
    GameListQuery? query,
    List<GameSummary>? items,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return DiscoverState(
      query: query ?? this.query,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Paginated game browser backing the Discover tab.
class DiscoverController extends Notifier<DiscoverState> {
  int _requestId = 0;

  @override
  DiscoverState build() {
    Future<void>.microtask(_loadFirstPage);
    return const DiscoverState();
  }

  void setSearch(String text) {
    final search = text.trim();
    if (search == (state.query.search ?? '')) return;
    _apply(_copyQuery(search: search));
  }

  void setSort(GameSort sort) {
    if (sort == state.query.sort) return;
    _apply(_copyQuery(sort: sort));
  }

  void setCategory(String? slug) {
    if (slug == state.query.category) return;
    _apply(_copyQuery(category: slug ?? ''));
  }

  Future<void> refresh() => _loadFirstPage();

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    final next = _copyQuery(page: state.query.page + 1);
    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await ref
          .read(discoveryRepositoryProvider)
          .listGames(next);
      if (requestId != _requestId) return;
      state = state.copyWith(
        query: next,
        items: <GameSummary>[...state.items, ...result.items],
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    }
  }

  void _apply(GameListQuery query) {
    state = state.copyWith(query: query);
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final requestId = ++_requestId;
    final query = _copyQuery(page: 1);
    state = state.copyWith(query: query, isLoading: true, clearError: true);

    try {
      final result = await ref
          .read(discoveryRepositoryProvider)
          .listGames(query);
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: result.items,
        hasMore: result.hasMore,
        isLoading: false,
      );
    } catch (error) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: const <GameSummary>[],
        isLoading: false,
        error: error,
      );
    }
  }

  /// Empty strings clear the corresponding filter.
  GameListQuery _copyQuery({
    int? page,
    String? search,
    String? category,
    GameSort? sort,
  }) {
    final q = state.query;
    String? orNull(String? v) => v == null || v.isEmpty ? null : v;

    return GameListQuery(
      page: page ?? 1,
      pageSize: q.pageSize,
      search: search == null ? q.search : orNull(search),
      category: category == null ? q.category : orNull(category),
      sort: sort ?? q.sort,
    );
  }
}

final discoverControllerProvider =
    NotifierProvider<DiscoverController, DiscoverState>(DiscoverController.new);
