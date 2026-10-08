import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.onSeeAll,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final seeAll = onSeeAll;

    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (seeAll != null)
            GestureDetector(
              onTap: seeAll,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
