import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
