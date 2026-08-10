import 'package:flutter/material.dart';

/// Brand and semantic colors for the khelam design system.
///
/// Light-scheme values follow the theme config
/// `docs/superpowers/specs/2026-08-09-theme-config.json` (2026-08-09).
abstract final class AppPalette {
  // Brand seeds — back the dark scheme and generated tone baselines.
  static const Color seed = Color(0xFF1A5F7A);
  static const Color secondarySeed = Color(0xFF57A773);
  static const Color tertiarySeed = Color(0xFFE8A838);

  static const Color errorDark = Color(0xFFFFB4AB);

  static const Color surfaceTintLight = Color(0xFF1A5F7A);
  static const Color surfaceTintDark = Color(0xFF8ECAE6);

  // Light scheme — theme config 2026-08-09 (explicit slots; seed #097339).
  static const Color primary = Color(0xFF097339);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE6F2EB);
  static const Color onPrimaryContainer = Color(0xFF097339);
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF9FAFA);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFFF3F4F3);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color error = Color(0xFFD9534F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDEAEA);
  static const Color onErrorContainer = Color(0xFFD9534F);
  static const Color outline = Color(0xFFE5E7EB);

  // Component extras — theme config 2026-08-09.
  static const Color cardShadow = Color(0x1A000000);
  static const Color cardBackground = Color(0x6DDEDEDE);
}
