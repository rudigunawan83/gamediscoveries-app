import 'package:flutter/material.dart';

class AppColors {
  static const Color night = Color(0xFF0B0B10);
  static const Color surface = Color(0xFF15151D);
  static const Color surfaceAlt = Color(0xFF1E1E29);
  static const Color card = Color(0xFF17171F);
  static const Color line = Color(0xFF2A2A37);

  static const Color gold = Color(0xFFFFC83D);
  static const Color goldDeep = Color(0xFFF5A524);
  static const Color onGold = Color(0xFF1A1205);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9C9CB0);
  static const Color textMuted = Color(0xFF6B6B7E);

  static const Color success = Color(0xFF2BD576);
  static const Color danger = Color(0xFFFF5D73);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color teal = Color(0xFF14B8A6);
  static const Color pink = Color(0xFFEC4899);
  static const Color orange = Color(0xFFF97316);
  static const Color silver = Color(0xFFC0C6D4);
  static const Color bronze = Color(0xFFD08A4E);

  static const LinearGradient goldGradient = LinearGradient(
    colors: <Color>[gold, goldDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Same stops as the web `bg-brand-gradient` (120deg).
  static const LinearGradient brandGradient = LinearGradient(
    colors: <Color>[Color(0xFFFFE08A), Color(0xFFF5B63B), Color(0xFFE07A20)],
    stops: <double>[0, 0.48, 1],
    begin: Alignment(-0.87, -0.5),
    end: Alignment(0.87, 0.5),
  );

  static const List<Color> accentCycle = <Color>[
    blue,
    teal,
    gold,
    purple,
    pink,
    orange,
    success,
  ];

  const AppColors._();
}
