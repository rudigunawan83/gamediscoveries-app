import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    required this.value,
    this.height = 8,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final double height;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final fill = color;

    return Semantics(
      label: semanticLabel,
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const ColoredBox(color: AppColors.surfaceAlt),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clamped,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fill,
                    gradient: fill == null ? AppColors.goldGradient : null,
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
