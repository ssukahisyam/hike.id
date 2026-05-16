import 'package:flutter/material.dart';

/// Typography scale — DESIGN.md §4.
///
/// Dua keluarga font:
/// - Inter untuk display & UI
/// - JetBrains Mono untuk angka stat & koordinat
///
/// Kalau font asset belum di-bundle, fallback ke system humanist & monospace.
class HTypography {
  HTypography._();

  static const String displayFamily = 'Inter';
  static const String monoFamily = 'JetBrainsMono';

  // Display & headings
  static TextStyle displayXl = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 36,
    height: 40 / 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.72, // -0.02em
  );

  static TextStyle displayLg = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.28,
  );

  static TextStyle headingXl = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
  );

  static TextStyle headingLg = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headingMd = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  // Body
  static TextStyle bodyLg = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMd = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySm = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
  );

  // Labels
  static TextStyle labelLg = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.28,
  );

  static TextStyle labelMd = const TextStyle(
    fontFamily: displayFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.48,
  );

  // Mono — stats & coordinates
  static TextStyle monoXl = const TextStyle(
    fontFamily: monoFamily,
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
  );

  static TextStyle monoLg = const TextStyle(
    fontFamily: monoFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
  );

  static TextStyle monoMd = const TextStyle(
    fontFamily: monoFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle monoSm = const TextStyle(
    fontFamily: monoFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
  );

  /// Convert ke TextTheme Material untuk dipasang ke ThemeData.
  static TextTheme toTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: displayXl.copyWith(color: primaryColor),
      displayMedium: displayLg.copyWith(color: primaryColor),
      displaySmall: headingXl.copyWith(color: primaryColor),
      headlineLarge: headingXl.copyWith(color: primaryColor),
      headlineMedium: headingLg.copyWith(color: primaryColor),
      headlineSmall: headingMd.copyWith(color: primaryColor),
      titleLarge: headingLg.copyWith(color: primaryColor),
      titleMedium: headingMd.copyWith(color: primaryColor),
      titleSmall: labelLg.copyWith(color: primaryColor),
      bodyLarge: bodyLg.copyWith(color: primaryColor),
      bodyMedium: bodyMd.copyWith(color: primaryColor),
      bodySmall: bodySm.copyWith(color: secondaryColor),
      labelLarge: labelLg.copyWith(color: primaryColor),
      labelMedium: labelMd.copyWith(color: secondaryColor),
      labelSmall: bodySm.copyWith(color: secondaryColor),
    );
  }
}
