import 'package:flutter/material.dart';

import 'theme/app_component_themes.dart';
import 'theme/app_palette.dart';
import 'theme/app_typography.dart';

/// Single source of truth for khelam [ThemeData] and [ColorScheme] values.
///
/// The Material 3 component preview must always receive themes from this class
/// via [ThemePreviewView].
class AppTheme {
  const AppTheme._();

  static ThemeData light() => forBrightness(Brightness.light);

  static ThemeData dark() => forBrightness(Brightness.dark);

  /// Builds the khelam theme for the given [brightness].
  static ThemeData forBrightness(Brightness brightness) {
    final ColorScheme colorScheme = colorSchemeFor(brightness);
    final TextTheme textTheme = AppTypography.textTheme(colorScheme);

    return AppComponentThemes.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: brightness,
    );
  }

  /// Resolves light or dark [ColorScheme] from [AppPalette] seed colors.
  static ColorScheme colorSchemeFor(Brightness brightness) {
    return brightness == Brightness.light ? lightColorScheme : darkColorScheme;
  }

  static ColorScheme get lightColorScheme =>
      AppComponentThemes.lightColorScheme();

  static ColorScheme get darkColorScheme =>
      AppComponentThemes.darkColorScheme();

  /// Brand seed colors used to generate [ColorScheme] values.
  static Color get seedColor => AppPalette.seed;

  static Color get secondarySeedColor => AppPalette.secondarySeed;

  static Color get tertiarySeedColor => AppPalette.tertiarySeed;

  static Color get errorColor => AppPalette.error;

  static Color get errorColorDark => AppPalette.errorDark;
}
