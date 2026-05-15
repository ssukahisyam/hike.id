import 'package:flutter/material.dart';

/// Shadow tokens — DESIGN.md §5.4.
///
/// Soft & warm, bukan harsh dropshadow.
/// Di dark mode, shadow umumnya tidak terlihat — gunakan border subtle.
class HShadows {
  HShadows._();

  static const Color _shadowColor = Color(0xFF141E12);

  static List<BoxShadow> level1 = const [
    BoxShadow(
      color: Color.fromRGBO(20, 30, 18, 0.06),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> level2 = const [
    BoxShadow(
      color: Color.fromRGBO(20, 30, 18, 0.08),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> level3 = const [
    BoxShadow(
      color: Color.fromRGBO(20, 30, 18, 0.12),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> level4 = const [
    BoxShadow(
      color: Color.fromRGBO(20, 30, 18, 0.16),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  static Color get rawColor => _shadowColor;
}
