import 'package:flutter/material.dart';

/// Design token — all colors in the Owly design system.
/// Never use hex literals in widget code; always reference these tokens.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color coral = Color(0xFFFF6B5E); // Expense / primary CTA
  static const Color teal = Color(0xFF3DD9C4); // Income / secondary

  // ── Dark theme surface stack ────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF191919);
  static const Color darkSurface = Color(0xFF242424);
  static const Color darkSurfaceElevated = Color(0xFF2E2E2E);
  static const Color darkCard = Color(0xFF232323);
  static const Color darkTextPrimary = Color(0xFFF5F5F3);
  static const Color darkTextSecondary = Color(0xFF9C9C9C);
  static const Color darkDivider = Color(0xFF333333);

  // ── Light theme surface stack ───────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAF8F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF2EFE8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF888888);
  static const Color lightDivider = Color(0xFFE8E4DC);

  // ── Semantic ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);

  // ── Category palette (12 tokens, round-robin assigned) ─────────────────
  static const Map<String, Color> categoryPalette = {
    'coral': Color(0xFFFF6B5E),
    'teal': Color(0xFF3DD9C4),
    'violet': Color(0xFF8B5CF6),
    'pink': Color(0xFFEC4899),
    'slate': Color(0xFF64748B),
    'red': Color(0xFFEF4444),
    'amber': Color(0xFFF59E0B),
    'sky': Color(0xFF0EA5E9),
    'lime': Color(0xFF84CC16),
    'indigo': Color(0xFF6366F1),
    'rose': Color(0xFFF43F5E),
    'stone': Color(0xFF78716C),
  };

  static Color fromToken(String token) => categoryPalette[token] ?? coral;

  /// Returns a very light tint of [color] for chip backgrounds.
  static Color chipBackground(Color color) => color.withValues(alpha: 0.15);
}
