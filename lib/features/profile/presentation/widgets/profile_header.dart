import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/locale_resolution.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.title, this.onSettings, super.key});

  final String title;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final settings = onSettings;

    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        if (settings != null)
          IconButton(
            tooltip: context.l10n.settingsTitle,
            onPressed: settings,
            style: IconButton.styleFrom(
              fixedSize: const Size.square(48),
              backgroundColor: Colors.black.withValues(alpha: 0.45),
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.6)),
              ),
            ),
            icon: const Icon(Icons.settings_rounded, size: 26),
          ),
      ],
    );
  }
}
