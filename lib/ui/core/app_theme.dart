import 'package:flutter/material.dart';

import 'package:commons/commons.dart';

import 'theme/app_palette.dart';

/// Single source of truth for khelam [ThemeData] and [ColorScheme] values.
///
/// The Material 3 component preview must always receive themes from this class
/// via [ThemePreviewView].
///
/// The light scheme follows the theme config
/// `docs/superpowers/specs/2026-08-09-theme-config.json`; the dark scheme
/// stays seed-derived. Deprecated `ColorScheme` slots from the config
/// (`background`, `onBackground`, `surfaceVariant`) are delivered via
/// [AppPalette] and the component layers instead of the scheme.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => forBrightness(Brightness.light);

  static ThemeData dark() => forBrightness(Brightness.dark);

  /// Builds the khelam theme for the given [brightness].
  static ThemeData forBrightness(Brightness brightness) {
    final ColorScheme colorScheme = colorSchemeFor(brightness);
    final TextTheme textTheme = AppTypography.textTheme(colorScheme);
    final bool isLight = brightness == Brightness.light;

    return ComponentThemes.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: brightness,
    ).copyWith(
      // Config typography: role-colored, safe for both brightnesses.
      textTheme: _configTextTheme(textTheme, colorScheme),
      // Config canvas (#F9FAFA); dark keeps the generated surface.
      scaffoldBackgroundColor: isLight
          ? AppPalette.background
          : colorScheme.surface,
      // Light-only component overrides — dark stays seed-derived.
      cardTheme: isLight ? _configCardTheme(colorScheme) : null,
      filledButtonTheme: isLight
          ? _configFilledButton(colorScheme, textTheme)
          : null,
      elevatedButtonTheme: isLight
          ? _configElevatedButton(colorScheme, textTheme)
          : null,
      outlinedButtonTheme: isLight
          ? _configOutlinedButton(colorScheme, textTheme)
          : null,
    );
  }

  /// Resolves light or dark [ColorScheme] from [AppPalette] seed colors.
  static ColorScheme colorSchemeFor(Brightness brightness) {
    return brightness == Brightness.light ? lightColorScheme : darkColorScheme;
  }

  /// Builds the light [ColorScheme] from the theme-config palette
  /// (seed #097339). Slots the config does not specify (`surfaceContainer*`,
  /// `outlineVariant`, `inverse*`, `surfaceTint`, ...) are tone-generated from
  /// the seed so the shared [ComponentThemes] keep working.
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
    seedColor: AppPalette.primary,
    brightness: Brightness.light,
    primary: AppPalette.primary,
    onPrimary: AppPalette.onPrimary,
    primaryContainer: AppPalette.primaryContainer,
    onPrimaryContainer: AppPalette.onPrimaryContainer,
    secondary: AppPalette.secondary,
    onSecondary: AppPalette.onSecondary,
    surface: AppPalette.surface,
    onSurface: AppPalette.onSurface,
    onSurfaceVariant: AppPalette.onSurfaceVariant,
    error: AppPalette.error,
    onError: AppPalette.onError,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
    outline: AppPalette.outline,
  );

  /// Builds the dark [ColorScheme] from the same brand seed as light
  /// (#097339) so the two brightnesses complement each other. Primary
  /// derives from the seed's dark tone table (no fixed-tint override).
  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
    seedColor: AppPalette.primary,
    brightness: Brightness.dark,
    secondary: AppPalette.secondarySeed,
    tertiary: AppPalette.tertiarySeed,
    error: AppPalette.errorDark,
  );

  // --- theme-config layers (2026-08-09) --------------------------------

  /// Applies the config typography on top of the shared [AppTypography]
  /// baseline. Colors are role references (resolved per brightness), so the
  /// same layer is safe for both themes.
  static TextTheme _configTextTheme(TextTheme base, ColorScheme c) {
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: c.onPrimary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: c.onSurfaceVariant,
      ),
    );
  }

  /// Card: config shape (radius 24), elevation 2, shadow color, surface fill.
  static CardThemeData _configCardTheme(ColorScheme c) {
    return CardThemeData(
      color: c.surface,
      elevation: 2,
      shadowColor: AppPalette.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // Keep the shared baseline's margin (config does not specify one).
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }

  /// Elevated button: primary fill, pill shape, no elevation, config padding.
  static FilledButtonThemeData _configFilledButton(ColorScheme c, TextTheme t) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 2,
        minimumSize: Size(0, 0),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        textStyle: t.bodyMedium?.copyWith(
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  /// Elevated button: primary fill, pill shape, no elevation, config padding.
  static ElevatedButtonThemeData _configElevatedButton(
    ColorScheme c,
    TextTheme t,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        minimumSize: Size(0, 0),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        textStyle: t.bodyMedium?.copyWith(
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  /// Outlined button: surface fill, primary content, pill shape, outline side.
  static OutlinedButtonThemeData _configOutlinedButton(
    ColorScheme c,
    TextTheme t,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, 0),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: c.surface,
        foregroundColor: c.primary,
        textStyle: t.bodyMedium?.copyWith(
          textBaseline: TextBaseline.alphabetic,
        ),
        side: BorderSide(color: c.outline, width: 1),
      ),
    );
  }

  /// Brand seed colors used to generate [ColorScheme] values.
  static Color get seedColor => AppPalette.seed;

  static Color get secondarySeedColor => AppPalette.secondarySeed;

  static Color get tertiarySeedColor => AppPalette.tertiarySeed;

  static Color get errorColor => AppPalette.error;

  static Color get errorColorDark => AppPalette.errorDark;
}
