import 'package:flutter/material.dart';
import 'package:spendra/core/theme/app_colors.dart';

/// Elevation shadow recipes.
/// Reserved for: balance card, FAB, modals. Everything else is flat.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x50FF6B5E),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 32,
      spreadRadius: 0,
      offset: Offset(0, -4),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, -4),
    ),
  ];

  /// Teal-tinted glow for income elements.
  static List<BoxShadow> get tealGlow => [
        BoxShadow(
          color: AppColors.teal.withValues(alpha: 0.25),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
}
