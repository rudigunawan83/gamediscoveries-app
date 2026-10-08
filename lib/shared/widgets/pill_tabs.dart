import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Gold pill selector used for Daily/Weekly, Global/Weekly/Monthly, etc.
///
/// With [expanded] the pills share the full width inside a track; otherwise
/// they scroll horizontally as standalone chips.
class PillTabs extends StatelessWidget {
  const PillTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.expanded = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool expanded;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Padding(
        padding: padding,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: <Widget>[
              for (var i = 0; i < labels.length; i++)
                Expanded(child: _pill(i, fill: true)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) =>
            _pill(index, fill: false),
      ),
    );
  }

  Widget _pill(int index, {required bool fill}) {
    final selected = index == selectedIndex;

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.gold
                : (fill ? Colors.transparent : AppColors.surfaceAlt),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            labels[index],
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.onGold : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
