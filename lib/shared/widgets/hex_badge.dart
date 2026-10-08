import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Hexagon emblem used for the level badge and achievement icons.
class HexBadge extends StatelessWidget {
  const HexBadge({
    required this.color,
    this.icon,
    this.child,
    this.size = 64,
    this.locked = false,
    super.key,
  });

  final Color color;
  final IconData? icon;
  final Widget? child;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final base = locked ? AppColors.textMuted : color;
    final content =
        child ??
        Icon(
          locked ? Icons.lock_rounded : icon,
          size: size * 0.42,
          color: locked ? AppColors.textSecondary : Colors.white,
        );

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _HexPainter(color: base, glow: !locked),
        child: Center(child: content),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  _HexPainter({required this.color, required this.glow});

  final Color color;
  final bool glow;

  Path _hexagon(Size size, double inset) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - inset;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 3 * i - math.pi / 2;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _hexagon(size, 1);
    final inner = _hexagon(size, size.shortestSide * 0.09);

    if (glow) {
      canvas.drawPath(
        outer,
        Paint()
          ..color = color.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Color.lerp(color, Colors.white, 0.35)!,
            Color.lerp(color, Colors.black, 0.25)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      inner,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Color.lerp(color, Colors.black, 0.15)!,
            Color.lerp(color, Colors.black, 0.55)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_HexPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.glow != glow;
  }
}
