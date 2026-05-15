import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_tokens.dart';
import 'spacing.dart';
import 'typography.dart';

/// App-wide theme builder.
///
/// Mengikuti tiga mode dari DESIGN.md §9: light, dark, outdoor.
class AppTheme {
  AppTheme._();

  /// Light theme — default day mode.
  static ThemeData light() => _build(HSurface.light, Brightness.light);

  /// Dark theme — default night / mengikuti sistem.
  static ThemeData dark() => _build(HSurface.dark, Brightness.dark);

  /// Outdoor theme — high contrast untuk terik matahari.
  ///
  /// Trade-off: lebih "kasar" — itu intentional sesuai DESIGN.md §9.3.
  static ThemeData outdoor() => _build(HSurface.outdoor, Brightness.light, isOutdoor: true);

  static ThemeData _build(
    HSurface surface,
    Brightness brightness, {
    bool isOutdoor = false,
  }) {
    final ColorScheme baseScheme = ColorScheme(
      brightness: brightness,
      primary: surface.actionPrimary,
      onPrimary: surface.actionPrimaryFg,
      secondary: surface.actionAccent,
      onSecondary: surface.actionAccentFg,
      error: HColors.danger,
      onError: HColors.mist0,
      surface: surface.surface,
      onSurface: surface.textPrimary,
    );

    final TextTheme textTheme = HTypography.toTextTheme(
      surface.textPrimary,
      surface.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      brightness: brightness,
      scaffoldBackgroundColor: surface.background,
      canvasColor: surface.background,
      dividerColor: surface.divider,
      textTheme: textTheme,
      fontFamily: HTypography.displayFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
      extensions: <ThemeExtension<dynamic>>[surface],
      appBarTheme: AppBarTheme(
        backgroundColor: surface.background,
        foregroundColor: surface.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: HTypography.headingLg.copyWith(color: surface.textPrimary),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: surface.surface,
        elevation: isOutdoor ? 0 : 1,
        shadowColor: const Color.fromRGBO(20, 30, 18, 0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HRadius.lg),
          side: BorderSide(
            color: surface.borderSubtle,
            width: isOutdoor ? 1.5 : 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.surface,
        selectedItemColor: surface.actionPrimary,
        unselectedItemColor: surface.textTertiary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: HTypography.labelMd,
        unselectedLabelStyle: HTypography.labelMd,
      ),
      dividerTheme: DividerThemeData(
        color: surface.divider,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HSpacing.s3,
          vertical: HSpacing.s3,
        ),
        labelStyle: HTypography.labelLg.copyWith(color: surface.textSecondary),
        hintStyle: HTypography.bodyLg.copyWith(color: surface.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HRadius.md),
          borderSide: BorderSide(color: surface.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HRadius.md),
          borderSide: BorderSide(color: surface.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HRadius.md),
          borderSide: BorderSide(color: surface.actionPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HRadius.md),
          borderSide: const BorderSide(color: HColors.danger),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface.textPrimary,
        contentTextStyle: HTypography.bodyMd.copyWith(color: surface.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HRadius.md),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
