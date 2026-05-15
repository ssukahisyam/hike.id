import 'package:flutter/animation.dart';

/// Motion tokens — DESIGN.md §10.
class HMotion {
  HMotion._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration lazy = Duration(milliseconds: 500);

  static const Cubic standard = Cubic(0.2, 0, 0, 1);
  static const Cubic decelerate = Cubic(0, 0, 0, 1);
  static const Cubic accelerate = Cubic(0.3, 0, 1, 1);
}
