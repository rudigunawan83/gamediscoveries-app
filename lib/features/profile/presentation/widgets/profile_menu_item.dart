import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A tappable profile row. A `null` [onTap] renders the row as unavailable
/// with a "Soon" badge instead of a chevron, so it never looks actionable.
class ProfileMenuItem extends StatefulWidget {
  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.accent,
    this.onTap,
    this.prominent = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onTap;

  /// Prominent rows get the tinted gradient card; others a neutral surface
  /// with only the icon in the accent color.
  final bool prominent;

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
  static final BorderRadius _radius = BorderRadius.circular(18);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final accent = widget.accent;
    final prominent = widget.prominent;

    final row = Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: _radius,
          color: prominent ? null : AppColors.surface,
          gradient: prominent
              ? LinearGradient(
                  colors: <Color>[
                    accent.withValues(alpha: 0.24),
                    accent.withValues(alpha: 0.08),
                    const Color(0xFF12141B),
                  ],
                  stops: const <double>[0, 0.45, 1],
                )
              : null,
          border: Border.all(
            color: prominent ? accent.withValues(alpha: 0.55) : AppColors.line,
            width: prominent ? 1.2 : 1,
          ),
          boxShadow: prominent
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: InkWell(
          borderRadius: _radius,
          onTap: widget.onTap,
          onHighlightChanged: (bool value) => setState(() => _pressed = value),
          splashColor: AppColors.gold.withValues(alpha: 0.12),
          highlightColor: AppColors.gold.withValues(alpha: 0.06),
          child: ClipRRect(
            borderRadius: _radius,
            child: Stack(
              children: <Widget>[
                if (prominent)
                  Positioned(
                    right: 56,
                    top: -10,
                    bottom: -10,
                    child: ExcludeSemantics(
                      child: Icon(
                        widget.icon,
                        size: 64,
                        color: accent.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: prominent ? 68 : 60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        _LeadingIcon(icon: widget.icon, accent: accent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: prominent ? 18 : 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (enabled) const _Chevron() else const _SoonBadge(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: enabled ? widget.label : '${widget.label}, coming soon',
      excludeSemantics: true,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Opacity(opacity: enabled ? 1 : 0.6, child: row),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Icon(
        icon,
        color: accent,
        size: 30,
        shadows: <Shadow>[
          Shadow(color: accent.withValues(alpha: 0.7), blurRadius: 14),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'Soon',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
