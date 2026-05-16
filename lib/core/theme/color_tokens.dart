import 'package:flutter/material.dart';

/// Color tokens for Hike.id.
///
/// Source of truth: DESIGN.md §3.
/// Palet terinspirasi dari landscape gunung Indonesia di pagi hari:
/// forest (hijau lumut), volcanic (tanah vulkanik), mist (kabut subuh),
/// alpenglow (cahaya matahari pagi).
///
/// Jangan pakai hex literal di luar file ini — selalu lewat token.
class HColors {
  HColors._();

  // Primary — Forest
  static const Color forest50 = Color(0xFFF2F7F3);
  static const Color forest100 = Color(0xFFDCEAE0);
  static const Color forest200 = Color(0xFFB6D2BF);
  static const Color forest300 = Color(0xFF87B294);
  static const Color forest400 = Color(0xFF5A8E69);
  static const Color forest500 = Color(0xFF2F6A40); // PRIMARY
  static const Color forest600 = Color(0xFF275836);
  static const Color forest700 = Color(0xFF1F4429);
  static const Color forest800 = Color(0xFF16321F);
  static const Color forest900 = Color(0xFF0E2014);

  // Secondary — Volcanic
  static const Color volcanic50 = Color(0xFFF8F6F4);
  static const Color volcanic100 = Color(0xFFECE7E1);
  static const Color volcanic200 = Color(0xFFD4CBBF);
  static const Color volcanic300 = Color(0xFFB5A595);
  static const Color volcanic400 = Color(0xFF8E7B6A);
  static const Color volcanic500 = Color(0xFF6B5A4A);
  static const Color volcanic600 = Color(0xFF524539);
  static const Color volcanic700 = Color(0xFF3C3329);
  static const Color volcanic800 = Color(0xFF2A241D);
  static const Color volcanic900 = Color(0xFF1A1611);

  // Accent — Alpenglow (hemat: hanya aksi paling penting)
  static const Color alpenglow300 = Color(0xFFFDB36A);
  static const Color alpenglow400 = Color(0xFFFA9540); // ACCENT
  static const Color alpenglow500 = Color(0xFFE87320);
  static const Color alpenglow600 = Color(0xFFC25A12);

  // Neutral — Mist
  static const Color mist0 = Color(0xFFFFFFFF);
  static const Color mist50 = Color(0xFFFAFAF9);
  static const Color mist100 = Color(0xFFF2F2F0);
  static const Color mist200 = Color(0xFFE4E4E1);
  static const Color mist300 = Color(0xFFC9C9C4);
  static const Color mist400 = Color(0xFFA1A19B);
  static const Color mist500 = Color(0xFF75756F);
  static const Color mist600 = Color(0xFF56564F);
  static const Color mist700 = Color(0xFF3E3E38);
  static const Color mist800 = Color(0xFF28281F);
  static const Color mist900 = Color(0xFF15150F);
  static const Color mist950 = Color(0xFF0A0A06);

  // Semantic — single representative colors per family.
  static const Color successBg = forest700;
  static const Color successFg = forest100;
  static const Color successBorder = forest500;

  static const Color warningBg = Color(0xFF5C4318);
  static const Color warningFg = alpenglow300;
  static const Color warningBorder = alpenglow400;

  static const Color dangerBg = Color(0xFF5A1F22);
  static const Color dangerFg = Color(0xFFF4D5D7);
  static const Color dangerBorder = Color(0xFFC8413E);
  static const Color danger = Color(0xFFC8413E);

  static const Color infoBg = Color(0xFF1F3A4D);
  static const Color infoFg = Color(0xFFC5DCED);
  static const Color infoBorder = Color(0xFF3E7195);
  static const Color info = Color(0xFF3E7195);

  // Map / tracking specialty
  static const Color trackActive = forest500;
  static const Color trackHistory = volcanic500;
  static const Color trackImported = info;

  static const Color gpsExcellent = forest500;
  static const Color gpsGood = alpenglow400;
  static const Color gpsWeak = danger;
  static const Color gpsNoSignal = mist300;

  static const Color elevationHigh = alpenglow300;
  static const Color elevationMid = forest300;
  static const Color elevationLow = forest700;
}

/// Bundles surface-level resolved colors per mode (light / dark / outdoor).
@immutable
class HSurface extends ThemeExtension<HSurface> {
  const HSurface({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.actionPrimary,
    required this.actionPrimaryFg,
    required this.actionAccent,
    required this.actionAccentFg,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color actionPrimary;
  final Color actionPrimaryFg;
  final Color actionAccent;
  final Color actionAccentFg;

  static const HSurface light = HSurface(
    background: HColors.mist0,
    surface: HColors.mist0,
    surfaceMuted: HColors.mist50,
    borderSubtle: HColors.mist200,
    borderDefault: HColors.mist300,
    borderStrong: HColors.mist400,
    divider: HColors.mist100,
    textPrimary: HColors.mist900,
    textSecondary: HColors.mist600,
    textTertiary: HColors.mist500,
    actionPrimary: HColors.forest500,
    actionPrimaryFg: HColors.mist0,
    actionAccent: HColors.alpenglow400,
    actionAccentFg: HColors.mist950,
  );

  static const HSurface dark = HSurface(
    background: HColors.mist950,
    surface: HColors.mist900,
    surfaceMuted: HColors.mist800,
    borderSubtle: HColors.mist800,
    borderDefault: HColors.mist700,
    borderStrong: HColors.mist600,
    divider: HColors.mist900,
    textPrimary: HColors.mist50,
    textSecondary: HColors.mist300,
    textTertiary: HColors.mist400,
    actionPrimary: HColors.forest400,
    actionPrimaryFg: HColors.mist0,
    actionAccent: HColors.alpenglow400,
    actionAccentFg: HColors.mist950,
  );

  /// Outdoor mode — high-contrast (≥ 7:1) untuk terbaca di terik tropis.
  static const HSurface outdoor = HSurface(
    background: HColors.mist0,
    surface: HColors.mist0,
    surfaceMuted: HColors.mist100,
    borderSubtle: HColors.mist400,
    borderDefault: HColors.mist500,
    borderStrong: HColors.mist700,
    divider: HColors.mist300,
    textPrimary: HColors.mist950,
    textSecondary: HColors.mist700,
    textTertiary: HColors.mist600,
    actionPrimary: HColors.forest700,
    actionPrimaryFg: HColors.mist0,
    actionAccent: HColors.alpenglow500,
    actionAccentFg: HColors.mist0,
  );

  @override
  HSurface copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? actionPrimary,
    Color? actionPrimaryFg,
    Color? actionAccent,
    Color? actionAccentFg,
  }) {
    return HSurface(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPrimaryFg: actionPrimaryFg ?? this.actionPrimaryFg,
      actionAccent: actionAccent ?? this.actionAccent,
      actionAccentFg: actionAccentFg ?? this.actionAccentFg,
    );
  }

  @override
  HSurface lerp(ThemeExtension<HSurface>? other, double t) {
    if (other is! HSurface) return this;
    return HSurface(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      actionPrimaryFg: Color.lerp(actionPrimaryFg, other.actionPrimaryFg, t)!,
      actionAccent: Color.lerp(actionAccent, other.actionAccent, t)!,
      actionAccentFg: Color.lerp(actionAccentFg, other.actionAccentFg, t)!,
    );
  }
}
