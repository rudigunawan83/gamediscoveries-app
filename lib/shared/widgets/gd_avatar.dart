import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class GdAvatar extends StatelessWidget {
  const GdAvatar({
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.ringColor,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final Color? ringColor;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color get _fallbackColor {
    final hash = name.codeUnits.fold<int>(0, (int a, int b) => a + b);
    return AppColors.accentCycle[hash % AppColors.accentCycle.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final ring = ringColor;
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    final avatar = ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: cacheSize,
                errorWidget: (BuildContext c, String u, Object e) =>
                    _Initials(text: _initials, color: _fallbackColor),
              )
            : _Initials(text: _initials, color: _fallbackColor),
      ),
    );

    return Semantics(
      label: name,
      image: true,
      child: ring == null
          ? avatar
          : Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 2),
              ),
              child: avatar,
            ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
