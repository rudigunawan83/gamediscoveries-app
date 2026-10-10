import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/locale_resolution.dart';
import '../../../../shared/widgets/gd_avatar.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.highlighted = true,
    this.onEditAvatar,
    this.avatarBusy = false,
    super.key,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;

  /// Signed-in players get the gold ring and glow; guests a neutral ring.
  final bool highlighted;

  /// Shows a camera badge and makes the avatar tappable when set.
  final VoidCallback? onEditAvatar;

  /// Dims the avatar with a spinner while an upload is in flight.
  final bool avatarBusy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = subtitle;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: Column(
        children: <Widget>[
          _EditableAvatar(
            onEdit: onEditAvatar,
            busy: avatarBusy,
            child: _GlowingAvatar(
              name: name,
              imageUrl: avatarUrl,
              highlighted: highlighted,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              shadows: const <Shadow>[
                Shadow(color: Colors.black54, blurRadius: 12),
              ],
            ),
          ),
          if (secondary != null && secondary.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              secondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.onEdit,
    required this.busy,
    required this.child,
  });

  final VoidCallback? onEdit;
  final bool busy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final edit = onEdit;
    if (edit == null) {
      return child;
    }

    return Semantics(
      button: true,
      enabled: !busy,
      label: busy
          ? context.l10n.profileUploadingAvatar
          : context.l10n.profileChangeAvatar,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: busy ? null : edit,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            if (busy)
              const Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 4,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFFFE08A), AppColors.gold],
                  ),
                  border: Border.all(color: AppColors.night, width: 3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 20,
                  color: AppColors.night,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowingAvatar extends StatelessWidget {
  const _GlowingAvatar({
    required this.name,
    required this.imageUrl,
    required this.highlighted,
  });

  static const double _size = 128;

  final String name;
  final String? imageUrl;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: highlighted
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFFFFE08A),
                  AppColors.gold,
                  AppColors.goldDeep,
                ],
              )
            : null,
        color: highlighted ? null : AppColors.line,
        boxShadow: highlighted
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.55),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: GdAvatar(
        name: name,
        imageUrl: imageUrl,
        size: _size,
        placeholder: _InitialsPlaceholder(
          initials: GdAvatar.initialsOf(name),
          highlighted: highlighted,
        ),
      ),
    );
  }
}

class _InitialsPlaceholder extends StatelessWidget {
  const _InitialsPlaceholder({
    required this.initials,
    required this.highlighted,
  });

  final String initials;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          colors: <Color>[Color(0xFF2A2416), Color(0xFF0E0E14)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: highlighted ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
