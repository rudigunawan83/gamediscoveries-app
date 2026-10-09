import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class ProfileStat {
  const ProfileStat({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    this.value,
    this.highlight = false,
  });

  final Widget icon;
  final String label;

  /// Screen readers need to tell apart metrics that share a visible label.
  final String semanticsLabel;

  /// `null` renders a dash: the metric is loading or unavailable.
  final int? value;
  final bool highlight;
}

/// Icon filled with a vertical gradient, for the glossy stat glyphs.
class GradientIcon extends StatelessWidget {
  const GradientIcon(
    this.icon, {
    required this.colors,
    this.size = 34,
    super.key,
  });

  final IconData icon;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class ProfileStatisticsCard extends StatelessWidget {
  const ProfileStatisticsCard({required this.stats, super.key});

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1B1A14), Color(0xFF101318)],
        ),
        borderRadius: radius,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.65),
          width: 1.4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.18),
            blurRadius: 26,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: <Widget>[
            const Positioned(left: 6, top: 14, child: _Sparkle(size: 12)),
            const Positioned(left: 4, bottom: 6, child: _Sparkle(size: 8)),
            const Positioned(right: 6, top: 22, child: _Sparkle(size: 10)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
              child: IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    for (var i = 0; i < stats.length; i++) ...<Widget>[
                      if (i > 0)
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.14),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      Expanded(child: _StatColumn(stat: stats[i])),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Icon(
        Icons.add_rounded,
        size: size,
        color: AppColors.gold.withValues(alpha: 0.55),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final value = stat.value;
    final display = value == null ? '—' : formatCompact(value);

    return Semantics(
      label: value == null
          ? '${stat.semanticsLabel}: not available'
          : '${stat.semanticsLabel}: $display',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.square(dimension: 38, child: Center(child: stat.icon)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                display,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: stat.highlight
                      ? AppColors.gold
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                stat.label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
