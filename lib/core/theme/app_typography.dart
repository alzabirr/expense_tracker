import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography token system using the Inter typeface.
abstract final class AppTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          // 40px Bold — balance figures, hero numbers
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            height: 1.1,
          ),
          // 28px Bold — modal titles
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.15,
          ),
          // 24px Bold — section titles
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          // 20px SemiBold — card titles
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.25,
          ),
          // 17px SemiBold — transaction title, list items
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            height: 1.35,
          ),
          // 15px Medium — body text, descriptions
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          // 14px Regular — secondary body
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          // 13px Regular — captions, helper text
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          // 12px SemiBold uppercase — eyebrow labels ("TOTAL BALANCE")
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            height: 1.3,
          ),
          // 14px SemiBold — button text, chip labels
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            height: 1.4,
          ),
        ),
      );
}
