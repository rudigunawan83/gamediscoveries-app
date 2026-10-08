import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/game_list_tile.dart';
import '../../../../shared/widgets/pill_tabs.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../favorites/presentation/favorite_button.dart';
import '../../domain/models/game_category.dart';
import '../../domain/models/game_list_query.dart';
import '../providers/discover_controller.dart';
import '../providers/discovery_providers.dart';

const List<(String, GameSort)> _sorts = <(String, GameSort)>[
  ('Trending', GameSort.trending),
  ('New', GameSort.newest),
  ('Popular', GameSort.popular),
  ('A–Z', GameSort.title),
];

const Duration _searchDebounce = Duration(milliseconds: 400);

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.text = ref.read(discoverControllerProvider).query.search ?? '';
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) {
      ref.read(discoverControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String text) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      ref.read(discoverControllerProvider.notifier).setSearch(text);
    });
  }

  void _clearSearch() {
    _search.clear();
    _debounce?.cancel();
    setState(() {});
    ref.read(discoverControllerProvider.notifier).setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverControllerProvider);
    final controller = ref.read(discoverControllerProvider.notifier);
    final sortIndex = _sorts.indexWhere(
      ((String, GameSort) s) => s.$2 == state.query.sort,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Discover'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: AppSearchField(
                  controller: _search,
                  onChanged: _onSearchChanged,
                  onClear: _search.text.isEmpty ? null : _clearSearch,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryRow(
                selected: state.query.category,
                onSelected: controller.setCategory,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: PillTabs(
                  expanded: false,
                  labels: <String>[for (final s in _sorts) s.$1],
                  selectedIndex: sortIndex < 0 ? 0 : sortIndex,
                  onChanged: (int i) => controller.setSort(_sorts[i].$2),
                ),
              ),
            ),
            ..._results(state, controller),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(DiscoverState state, DiscoverController controller) {
    if (state.isLoading && state.items.isEmpty) {
      return const <Widget>[SliverFillRemaining(child: LoadingView())];
    }

    final error = state.error;
    if (error != null) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(error: error, onRetry: controller.refresh),
        ),
      ];
    }

    if (state.items.isEmpty) {
      return const <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView(
            icon: Icons.search_off_rounded,
            title: 'No games found',
            message: 'Try another keyword or category.',
          ),
        ),
      ];
    }

    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: state.items.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final game = state.items[index];
            return GameListTile(
              game: game,
              trailing: FavoriteButton(gameId: game.id),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: state.isLoadingMore
              ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
              : const SizedBox.shrink(),
        ),
      ),
    ];
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.watch(categoriesProvider).value ?? const <GameCategory>[];
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _CategoryItem(
              label: 'All',
              icon: Icons.apps_rounded,
              color: AppColors.gold,
              selected: selected == null,
              onTap: () => onSelected(null),
            );
          }

          final category = categories[index - 1];
          return _CategoryItem(
            label: category.name,
            icon: categoryIcon(category.slug),
            color: AppColors.accentCycle[index % AppColors.accentCycle.length],
            selected: selected == category.slug,
            onTap: () => onSelected(category.slug),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 64,
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: selected ? 0.3 : 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData categoryIcon(String slug) {
  final s = slug.toLowerCase();
  if (s.contains('action')) return Icons.flash_on_rounded;
  if (s.contains('puzzle')) return Icons.extension_rounded;
  if (s.contains('racing') || s.contains('car')) {
    return Icons.directions_car_rounded;
  }
  if (s.contains('sport')) return Icons.sports_soccer_rounded;
  if (s.contains('shoot')) return Icons.gps_fixed_rounded;
  if (s.contains('adventure')) return Icons.explore_rounded;
  if (s.contains('strategy')) return Icons.psychology_rounded;
  if (s.contains('arcade')) return Icons.videogame_asset_rounded;
  if (s.contains('girl') || s.contains('dress')) return Icons.checkroom_rounded;
  if (s.contains('multi')) return Icons.groups_rounded;
  if (s.contains('hyper') || s.contains('casual')) return Icons.bolt_rounded;
  return Icons.sports_esports_rounded;
}
