import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/locale_resolution.dart';
import '../../../../core/utils/formatters.dart';
import '../../../progress/domain/progress_models.dart';

/// Renders the server-provided level; `null` shows a neutral placeholder
/// while progress is loading.
class ProfileXpProgress extends StatelessWidget {
  const ProfileXpProgress({required this.level, super.key});

  static const double _barHeight = 16;

  final LevelInfo? level;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final info = level;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final l10n = context.l10n;
    final semantics = info == null
        ? l10n.profileLevelLoadingSemantics
        : info.isMaxLevel
        ? l10n.profileLevelMaxSemantics(info.level)
        : l10n.profileLevelProgressSemantics(
            info.level,
            info.currentLevelXp,
            info.nextLevelXp,
          );
    final target = info == null ? 0.0 : info.progress.clamp(0.0, 1.0);
    final labelStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );

    return Semantics(
      label: semantics,
      value: '${(target * 100).round()}%',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: animate ? 0 : target, end: target),
            duration: animate
                ? const Duration(milliseconds: 900)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double value, Widget? child) =>
                _Bar(value: value, height: _barHeight),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(
                  info == null
                      ? l10n.profileLevelUnknown
                      : l10n.progressLevel(info.level),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text.rich(
                  _xpSpan(l10n, info),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static InlineSpan _xpSpan(AppLocalizations l10n, LevelInfo? info) {
    const muted = TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );
    if (info == null) return const TextSpan(text: '— XP', style: muted);
    if (info.isMaxLevel) {
      return TextSpan(
        text: l10n.profileMaxLevel,
        style: const TextStyle(color: AppColors.gold),
      );
    }
    return TextSpan(
      children: <InlineSpan>[
        TextSpan(text: formatGrouped(l10n, info.currentLevelXp)),
        TextSpan(
          text: ' / ${formatGrouped(l10n, info.nextLevelXp)} XP',
          style: muted,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.height});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);

    return Container(
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2230),
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.55),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: const CustomPaint(painter: _StripedFillPainter()),
            ),
          ),
        ),
      ),
    );
  }
}

class _StripedFillPainter extends CustomPainter {
  const _StripedFillPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFE27A),
            AppColors.gold,
            AppColors.goldDeep,
          ],
        ).createShader(rect),
    );

    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.16);
    const gap = 12.0;
    final h = size.height;
    for (var x = -h; x < size.width; x += gap) {
      canvas.drawPath(
        Path()
          ..moveTo(x, h)
          ..lineTo(x + h, 0)
          ..lineTo(x + h + gap / 2, 0)
          ..lineTo(x + gap / 2, h)
          ..close(),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_StripedFillPainter oldDelegate) => false;
}
