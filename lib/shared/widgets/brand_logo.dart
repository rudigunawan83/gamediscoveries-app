import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

const String _logoMarkAsset = 'assets/images/logo_mark.png';

/// GameDiscoveries logo matching the web frontend: gold "G" controller mark
/// plus "Game" + gradient "Discoveries" wordmark.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    this.markSize = 96,
    this.fontSize = 30,
    this.vertical = true,
    this.showTagline = false,
    super.key,
  });

  final double markSize;
  final double fontSize;

  /// Mark above the wordmark; otherwise side by side like the web header.
  final bool vertical;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      _logoMarkAsset,
      width: markSize,
      height: markSize,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    final wordmark = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'Game'),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) =>
                      AppColors.brandGradient.createShader(bounds),
                  child: Text(
                    'Discoveries',
                    style: _wordStyle.copyWith(fontSize: fontSize),
                  ),
                ),
              ),
            ],
          ),
          style: _wordStyle.copyWith(fontSize: fontSize),
        ),
        if (showTagline) ...<Widget>[
          SizedBox(height: fontSize * 0.25),
          Text(
            'FIND PLAY EXPLORE MORE',
            style: TextStyle(
              fontSize: fontSize * 0.36,
              fontWeight: FontWeight.w600,
              letterSpacing: fontSize * 0.1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      label: 'GameDiscoveries',
      excludeSemantics: true,
      child: vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                mark,
                SizedBox(height: markSize * 0.12),
                wordmark,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                mark,
                SizedBox(width: markSize * 0.25),
                wordmark,
              ],
            ),
    );
  }
}

const TextStyle _wordStyle = TextStyle(
  fontWeight: FontWeight.w900,
  letterSpacing: -0.5,
  color: Colors.white,
  height: 1.1,
);
