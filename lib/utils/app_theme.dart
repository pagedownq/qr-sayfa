import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

class AppTheme {
  // Core Colors
  static const Color primaryBlue = Color(0xFF00D2FF);
  static const Color primaryPurple = CupertinoColors.systemPurple;
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color glassBackground = Color(0xF21E293B);
  
  // Specific Use Cases
  static const Color textLight = CupertinoColors.white;
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0x1EFFFFFF);
  static const Color shadowDark = Color(0x66000000);
  
  // Gradients
  static const List<Color> defaultGradient = [
    Color(0xFF00D2FF),
    Color(0xFF3A7BD5)
  ];
}
