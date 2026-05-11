import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF6F1E9);
  static const Color textStrong = Color(0xFF1F2937);
  static const Color textSoft = Color(0xFF475569);
  static const Color outline = Color(0xFFE2E8F0);
}

class AppGradients {
  static const LinearGradient auth = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hero = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF1F2937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient header(Color color) {
    return LinearGradient(
      colors: [color.withOpacity(0.95), color.withOpacity(0.6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
