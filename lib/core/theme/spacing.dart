/// Spacing scale (4px base) — DESIGN.md §5.1.
///
/// Sebisa mungkin pakai kelipatan 4. Hindari nilai sembarang.
class HSpacing {
  HSpacing._();

  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
  static const double s20 = 80;

  // Layout
  static const double screenPaddingH = s5; // 20
  static const double cardGap = s3; // 12
  static const double sectionGap = s8; // 32
}

/// Border radius tokens — DESIGN.md §5.3.
class HRadius {
  HRadius._();

  static const double none = 0;
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static const double full = 9999;
}
