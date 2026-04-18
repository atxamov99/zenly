import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// Liquid Glass dizayn tili konstantalari.
/// Ma'lumotnoma: docs/superpowers/specs/2026-04-17-blink-ux-vision.md
class GlassTokens {
  GlassTokens._();

  // Blur hierarchy
  static const double blurThin = 8;
  static const double blurRegular = 20;
  static const double blurThick = 40;
  static const double blurUltra = 80;

  // Tint system (light mode — oq asosli)
  static const Color tintBase = Color(0x0FFFFFFF); // 6%
  static const Color tintElevated = Color(0x24FFFFFF); // 14%
  static const Color tintProminent = Color(0x3DFFFFFF); // 24%

  // Strokes
  static const Color strokeSpecular = Color(0x6BFFFFFF); // 42%
  static const Color strokeContour = Color(0x14000000); // 8%

  // Concentric corner radii
  static const double radiusOuter = 32;
  static const double radiusCard = 24;
  static const double radiusButton = 16;
  static const double radiusIconBg = 10;

  // Capsule (bottom nav)
  static const double capsuleHeight = 56;
  static const double capsuleRadius = 28;
  static const double capsuleHorizontalMargin = 16;
  static const double capsuleBottomGap = 12;

  // Spring physics
  static const Cubic spring = Cubic(0.32, 0.72, 0, 1);
  static const Duration springDuration = Duration(milliseconds: 450);
}
