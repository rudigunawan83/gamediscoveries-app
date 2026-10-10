import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../../shared/widgets/gold_tab.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../../notifications/presentation/notifications_providers.dart';
import '../domain/leaderboard_models.dart';
import 'leaderboard_providers.dart';

const double _maxContentWidth = 560;

String _entryName(AppLocalizations l10n, LeaderboardEntry entry) =>
    entry.name.isEmpty ? l10n.profileDefaultName : entry.name;

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(leaderboardDetailProvider(_scope));
    final signedIn = ref.watch(isSignedInProvider).value ?? false;
    final unread = ref.watch(unreadNotificationsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          l10n.profileLeaderboard,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.commonNotifications,
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: AppColors.danger,
              child: const Icon(Icons.notifications_none_rounded, size: 28),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _Centered(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _ScopeTabs(
                selected: _scope,
                onChanged: (LeaderboardScope s) => setState(() => _scope = s),
              ),
            ),
            Expanded(
              child: detail.when(
                skipLoadingOnRefresh: true,
                data: (LeaderboardDetail? data) {
                  if (data == null || data.items.isEmpty) {
                    return MessageView(
                      icon: Icons.leaderboard_rounded,
                      title: l10n.leaderboardEmptyTitle,
                      message: l10n.leaderboardEmptyMessage,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.refresh(leaderboardDetailProvider(_scope).future),
                    child: _Board(data: data),
                  );
                },
                loading: () => const LoadingView(),
                error: (Object error, StackTrace stackTrace) => ErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(leaderboardDetailProvider(_scope)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MyRankBar(me: detail.value?.me, signedIn: signedIn),
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

class _ScopeTabs extends StatelessWidget {
  const _ScopeTabs({required this.selected, required this.onChanged});

  final LeaderboardScope selected;
  final ValueChanged<LeaderboardScope> onChanged;

  static String _label(AppLocalizations l10n, LeaderboardScope scope) =>
      switch (scope) {
        LeaderboardScope.global => l10n.leaderboardScopeGlobal,
        LeaderboardScope.weekly => l10n.leaderboardScopeWeekly,
        LeaderboardScope.monthly => l10n.leaderboardScopeMonthly,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      spacing: 10,
      children: <Widget>[
        for (final scope in LeaderboardScope.values)
          Expanded(
            child: GoldTab(
              label: _label(l10n, scope),
              selected: scope == selected,
              onTap: () => onChanged(scope),
            ),
          ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.data});

  final LeaderboardDetail data;

  @override
  Widget build(BuildContext context) {
    final podium = data.items.take(3).toList(growable: false);
    final rest = data.items.skip(3).toList(growable: false);
    final remaining = formatTimeUntil(context.l10n, data.periodEndsAt);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: <Widget>[
        if (remaining.isNotEmpty)
          Center(
            child: Text(
              context.l10n.leaderboardSeasonEndsIn(remaining),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 8),
        _Podium(entries: podium),
        const SizedBox(height: 20),
        for (final entry in rest)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RankRow(
              entry: entry,
              isMe: entry.userId == data.me?.userId,
            ),
          ),
      ],
    );
  }
}

Color _placeColor(int place) => switch (place) {
  1 => AppColors.gold,
  2 => AppColors.silver,
  _ => AppColors.bronze,
};

class _Podium extends StatelessWidget {
  const _Podium({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? at(int i) => i < entries.length ? entries[i] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 44),
            child: _PodiumSpot(entry: at(1), place: 2),
          ),
        ),
        Expanded(flex: 4, child: _PodiumSpot(entry: at(0), place: 1)),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 44),
            child: _PodiumSpot(entry: at(2), place: 3),
          ),
        ),
      ],
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({required this.entry, required this.place});

  final LeaderboardEntry? entry;
  final int place;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    if (e == null) return const SizedBox.shrink();

    final first = place == 1;
    final color = _placeColor(place);
    final avatarSize = first ? 92.0 : 72.0;
    final l10n = context.l10n;

    return Semantics(
      container: true,
      label: l10n.leaderboardPodiumSemantics(
        place,
        _entryName(l10n, e),
        e.score,
      ),
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: first ? 150 : 100,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: <Widget>[
                if (first)
                  const Positioned.fill(
                    child: CustomPaint(painter: _CrestPainter()),
                  ),
                Positioned(
                  top: first ? 26 : 4,
                  child: _RingedAvatar(
                    entry: e,
                    size: avatarSize,
                    color: color,
                    glow: first ? 0.6 : 0.35,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: _PlaceBadge(place: place, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _entryName(l10n, e),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: first ? 16 : 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.commonXpAmount(e.score),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({
    required this.entry,
    required this.size,
    required this.color,
    this.glow = 0,
  });

  final LeaderboardEntry entry;
  final double size;
  final Color color;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size > 60 ? 4 : 2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color.lerp(color, Colors.white, 0.45)!, color],
        ),
        boxShadow: glow > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: glow),
                  blurRadius: size * 0.3,
                ),
              ]
            : null,
      ),
      child: GdAvatar(
        name: _entryName(context.l10n, entry),
        imageUrl: entry.avatarUrl,
        size: size,
      ),
    );
  }
}

class _PlaceBadge extends StatelessWidget {
  const _PlaceBadge({required this.place, required this.color});

  final int place;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = place == 1 ? 36.0 : 30.0;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color.lerp(color, Colors.white, 0.35)!, color],
        ),
        border: Border.all(color: AppColors.night, width: 3),
      ),
      child: Text(
        '$place',
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w900,
          color: AppColors.onGold,
        ),
      ),
    );
  }
}

/// Gold shield crest with crown points behind the #1 avatar.
class _CrestPainter extends CustomPainter {
  const _CrestPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = math.min(size.width, 132.0);
    final left = (size.width - w) / 2;
    final top = 8.0;
    final h = size.height - 22;

    final shield = Path()
      ..moveTo(left + w * 0.5, top)
      ..lineTo(left + w * 0.62, top + h * 0.08)
      ..lineTo(left + w * 0.9, top + h * 0.12)
      ..quadraticBezierTo(
        left + w,
        top + h * 0.45,
        left + w * 0.82,
        top + h * 0.8,
      )
      ..lineTo(left + w * 0.5, top + h)
      ..lineTo(left + w * 0.18, top + h * 0.8)
      ..quadraticBezierTo(left, top + h * 0.45, left + w * 0.1, top + h * 0.12)
      ..lineTo(left + w * 0.38, top + h * 0.08)
      ..close();
    final bounds = shield.getBounds();

    canvas.drawPath(
      shield,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFFFE9A6), AppColors.gold, Color(0xFF9A6410)],
        ).createShader(bounds),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFF1C2),
    );

    // Crown points along the top edge.
    final crown = Paint()..color = const Color(0xFFFFE08A);
    for (final dx in <double>[-0.16, 0, 0.16]) {
      final cx = left + w * (0.5 + dx);
      final peak = dx == 0 ? top - 8 : top + 2;
      canvas.drawPath(
        Path()
          ..moveTo(cx - 6, top + 12)
          ..lineTo(cx, peak)
          ..lineTo(cx + 6, top + 12)
          ..close(),
        crown,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrestPainter oldDelegate) => false;
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, this.isMe = false, this.docked = false});

  final LeaderboardEntry entry;
  final bool isMe;

  /// The gold "You" bar pinned to the bottom of the screen.
  final bool docked;

  @override
  Widget build(BuildContext context) {
    final change = entry.rankChange;
    final level = entry.level;
    final foreground = docked ? AppColors.onGold : AppColors.textPrimary;
    final secondary = docked
        ? AppColors.onGold.withValues(alpha: 0.75)
        : AppColors.textSecondary;
    final l10n = context.l10n;
    final name = isMe ? l10n.commonYou : _entryName(l10n, entry);
    final subtitle = level != null
        ? l10n.commonLevelShort(level)
        : l10n.progressGamesPlayed(entry.gamesPlayed);

    return Semantics(
      container: true,
      label: l10n.leaderboardRowSemantics(
        entry.rank,
        name,
        subtitle,
        entry.score,
      ),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: docked
              ? const LinearGradient(
                  colors: <Color>[Color(0xFFFFD866), AppColors.gold],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF1A1D26), Color(0xFF12141B)],
                ),
          border: Border.all(
            color: docked
                ? AppColors.gold
                : (isMe
                      ? AppColors.gold.withValues(alpha: 0.7)
                      : AppColors.line),
          ),
          boxShadow: docked
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: Text(
                docked ? '#${entry.rank}' : '${entry.rank}',
                style: TextStyle(
                  fontSize: docked ? 16 : 18,
                  fontWeight: FontWeight.w900,
                  color: foreground,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _RingedAvatar(
              entry: entry,
              size: 42,
              color: docked ? AppColors.onGold : AppColors.gold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: secondary),
                  ),
                ],
              ),
            ),
            if (change != null && change != 0) ...<Widget>[
              _RankChange(change: change, onGold: docked),
              const SizedBox(width: 10),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 112),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.commonXpAmount(entry.score),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: foreground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankChange extends StatelessWidget {
  const _RankChange({required this.change, required this.onGold});

  final int change;
  final bool onGold;

  @override
  Widget build(BuildContext context) {
    final up = change > 0;
    final color = onGold
        ? AppColors.onGold
        : (up ? AppColors.success : AppColors.danger);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
          color: color,
          size: 22,
        ),
        Text(
          '${change.abs()}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MyRankBar extends StatelessWidget {
  const _MyRankBar({required this.me, required this.signedIn});

  final LeaderboardEntry? me;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final entry = me;
    final l10n = context.l10n;

    return ColoredBox(
      color: AppColors.night,
      child: SafeArea(
        top: false,
        child: _Centered(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: entry != null
                ? _RankRow(entry: entry, isMe: true, docked: true)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.person_pin_circle_rounded,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              signedIn
                                  ? l10n.leaderboardPlayToRank
                                  : l10n.leaderboardSignInToRank,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        if (!signedIn)
                          TextButton(
                            onPressed: () => context.push(AppRoutes.login),
                            child: Text(l10n.commonSignIn),
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
