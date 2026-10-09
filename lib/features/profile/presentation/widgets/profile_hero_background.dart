import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Static gold pixel-art backdrop behind the profile header. Painted once and
/// isolated in its own layer so scrolling never repaints it.
class ProfileHeroBackground extends StatelessWidget {
  const ProfileHeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const CustomPaint(painter: _HeroPainter()),
            Align(
              alignment: const Alignment(-0.82, 0.38),
              child: Icon(
                Icons.sports_esports_rounded,
                size: 44,
                color: AppColors.gold.withValues(alpha: 0.22),
              ),
            ),
            Align(
              alignment: const Alignment(0.62, -0.62),
              child: Icon(
                Icons.diamond_rounded,
                size: 20,
                color: AppColors.gold.withValues(alpha: 0.28),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x00000000), AppColors.night],
                  stops: <double>[0.55, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  // (x, y, size, opacity) as fractions of the canvas.
  static const List<(double, double, double, double)> _pixels =
      <(double, double, double, double)>[
        (0.08, 0.22, 10, 0.35),
        (0.16, 0.58, 7, 0.45),
        (0.27, 0.12, 6, 0.30),
        (0.70, 0.30, 12, 0.40),
        (0.76, 0.18, 7, 0.55),
        (0.88, 0.46, 9, 0.35),
        (0.93, 0.66, 14, 0.45),
        (0.58, 0.08, 8, 0.25),
        (0.05, 0.78, 12, 0.30),
        (0.84, 0.82, 8, 0.30),
      ];

  static const List<(double, double, double)> _sparkles =
      <(double, double, double)>[
        (0.22, 0.42, 7),
        (0.82, 0.58, 8),
        (0.95, 0.30, 6),
        (0.12, 0.10, 5),
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 0.75,
          colors: <Color>[
            AppColors.gold.withValues(alpha: 0.20),
            AppColors.gold.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );

    _staircase(
      canvas,
      size,
      start: Offset(-30, h * 0.80),
      step: w * 0.11,
      rise: h * 0.085,
      width: 26,
      opacity: 0.22,
    );
    _staircase(
      canvas,
      size,
      start: Offset(-10, h * 0.70),
      step: w * 0.11,
      rise: h * 0.085,
      width: 8,
      opacity: 0.55,
    );
    _staircase(
      canvas,
      size,
      start: Offset(w * 0.30, h * 0.98),
      step: w * 0.10,
      rise: h * 0.09,
      width: 14,
      opacity: 0.16,
    );

    for (final (x, y, s, a) in _pixels) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(w * x, h * y), width: s, height: s),
        Paint()..color = AppColors.gold.withValues(alpha: a),
      );
    }

    final sparkle = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (final (x, y, r) in _sparkles) {
      final c = Offset(w * x, h * y);
      canvas
        ..drawLine(c.translate(-r, 0), c.translate(r, 0), sparkle)
        ..drawLine(c.translate(0, -r), c.translate(0, r), sparkle);
    }

    _crown(canvas, Offset(w * 0.86, h * 0.62), 30);
  }

  void _staircase(
    Canvas canvas,
    Size size, {
    required Offset start,
    required double step,
    required double rise,
    required double width,
    required double opacity,
  }) {
    final path = Path()..moveTo(start.dx, start.dy);
    var p = start;
    while (p.dx < size.width + step && p.dy > -rise) {
      p = p.translate(step, 0);
      path.lineTo(p.dx, p.dy);
      p = p.translate(0, -rise);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.miter
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.goldDeep.withValues(alpha: opacity * 0.6),
            AppColors.gold.withValues(alpha: opacity),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  void _crown(Canvas canvas, Offset center, double size) {
    final half = size / 2;
    final path = Path()
      ..moveTo(center.dx - half, center.dy + half * 0.6)
      ..lineTo(center.dx - half, center.dy - half * 0.4)
      ..lineTo(center.dx - half * 0.45, center.dy + half * 0.05)
      ..lineTo(center.dx, center.dy - half * 0.7)
      ..lineTo(center.dx + half * 0.45, center.dy + half * 0.05)
      ..lineTo(center.dx + half, center.dy - half * 0.4)
      ..lineTo(center.dx + half, center.dy + half * 0.6)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.gold.withValues(alpha: 0.32),
    );
  }

  @override
  bool shouldRepaint(_HeroPainter oldDelegate) => false;
}
