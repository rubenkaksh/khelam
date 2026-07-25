import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppComponentThemes {
  static ThemeData build({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Brightness brightness,
  }) {
    final bool isLight = brightness == Brightness.light;
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));
    const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(28));
    const OutlinedBorder buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surfaceContainerLow,
      dividerColor: colorScheme.outlineVariant,
      splashColor: colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: colorScheme.primary.withValues(alpha: 0.08),
      appBarTheme: _appBarTheme(colorScheme, textTheme),
      navigationBarTheme: _navigationBarTheme(colorScheme, textTheme),
      navigationRailTheme: _navigationRailTheme(colorScheme, textTheme),
      navigationDrawerTheme: _navigationDrawerTheme(colorScheme, textTheme),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colorScheme),
      drawerTheme: _drawerTheme(colorScheme, borderRadius),
      cardTheme: _cardTheme(colorScheme, borderRadius, isLight),
      dialogTheme: _dialogTheme(colorScheme, textTheme, dialogRadius),
      bottomSheetTheme: _bottomSheetTheme(colorScheme),
      snackBarTheme: _snackBarTheme(colorScheme, textTheme, borderRadius),
      bannerTheme: _bannerTheme(colorScheme, textTheme),
      chipTheme: _chipTheme(colorScheme, textTheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme, textTheme, buttonShape),
      filledButtonTheme: _filledButtonTheme(colorScheme, textTheme, buttonShape),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme, textTheme, buttonShape),
      textButtonTheme: _textButtonTheme(colorScheme, textTheme),
      segmentedButtonTheme: _segmentedButtonTheme(),
      iconButtonTheme: _iconButtonTheme(colorScheme),
      floatingActionButtonTheme: _floatingActionButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme, textTheme, borderRadius),
      checkboxTheme: _checkboxTheme(colorScheme),
      radioTheme: _radioTheme(colorScheme),
      switchTheme: _switchTheme(colorScheme),
      sliderTheme: _sliderTheme(colorScheme, textTheme),
      progressIndicatorTheme: _progressIndicatorTheme(colorScheme),
      listTileTheme: _listTileTheme(colorScheme, textTheme, borderRadius),
      expansionTileTheme: _expansionTileTheme(colorScheme, textTheme, borderRadius),
      tabBarTheme: _tabBarTheme(colorScheme, textTheme),
      tooltipTheme: _tooltipTheme(colorScheme, textTheme),
      popupMenuTheme: _popupMenuTheme(colorScheme, textTheme, borderRadius),
      menuTheme: _menuTheme(colorScheme, borderRadius),
      menuBarTheme: _menuBarTheme(colorScheme),
      dropdownMenuTheme: _dropdownMenuTheme(textTheme, borderRadius),
      searchBarTheme: _searchBarTheme(colorScheme, textTheme),
      searchViewTheme: _searchViewTheme(colorScheme, textTheme),
      badgeTheme: _badgeTheme(colorScheme, textTheme),
      dividerTheme: _dividerTheme(colorScheme),
      dataTableTheme: _dataTableTheme(colorScheme, textTheme),
      datePickerTheme: _datePickerTheme(colorScheme, textTheme),
      timePickerTheme: _timePickerTheme(colorScheme),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  // -- Navigation

  static AppBarTheme _appBarTheme(ColorScheme c, TextTheme t) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 3,
      centerTitle: false,
      backgroundColor: c.surface,
      foregroundColor: c.onSurface,
      surfaceTintColor: c.surfaceTint,
      titleTextStyle: t.titleLarge?.copyWith(color: c.onSurface),
      iconTheme: IconThemeData(color: c.onSurfaceVariant),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(ColorScheme c, TextTheme t) {
    return NavigationBarThemeData(
      elevation: 3,
      height: 80,
      backgroundColor: c.surfaceContainer,
      indicatorColor: c.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return t.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected)
            ? c.onSecondaryContainer
            : c.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
            ? c.onSecondaryContainer
            : c.onSurfaceVariant,
        );
      }),
    );
  }

  static NavigationRailThemeData _navigationRailTheme(ColorScheme c, TextTheme t) {
    return NavigationRailThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.secondaryContainer,
      selectedIconTheme: IconThemeData(color: c.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: c.onSurfaceVariant),
      selectedLabelTextStyle: t.labelMedium?.copyWith(color: c.onSurface),
      unselectedLabelTextStyle: t.labelMedium?.copyWith(color: c.onSurfaceVariant),
    );
  }

  static NavigationDrawerThemeData _navigationDrawerTheme(ColorScheme c, TextTheme t) {
    return NavigationDrawerThemeData(
      backgroundColor: c.surfaceContainerLow,
      indicatorColor: c.secondaryContainer,
      elevation: 1,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return t.labelLarge?.copyWith(
          color: states.contains(WidgetState.selected)
            ? c.onSecondaryContainer
            : c.onSurface,
        );
      }),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme(ColorScheme c) {
    return BottomNavigationBarThemeData(
      backgroundColor: c.surfaceContainer,
      selectedItemColor: c.onSecondaryContainer,
      unselectedItemColor: c.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 3,
    );
  }

  // -- Surfaces

  static DrawerThemeData _drawerTheme(ColorScheme c, BorderRadius br) {
    return DrawerThemeData(
      backgroundColor: c.surfaceContainerLow,
      surfaceTintColor: c.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: br),
    );
  }

  static CardThemeData _cardTheme(ColorScheme c, BorderRadius br, bool isLight) {
    return CardThemeData(
      elevation: isLight ? 1 : 2,
      color: c.surfaceContainerLow,
      surfaceTintColor: c.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: br),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }

  static DialogThemeData _dialogTheme(ColorScheme c, TextTheme t, BorderRadius dr) {
    return DialogThemeData(
      backgroundColor: c.surfaceContainerHigh,
      surfaceTintColor: c.surfaceTint,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: dr),
      titleTextStyle: t.headlineSmall?.copyWith(color: c.onSurface),
      contentTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(ColorScheme c) {
    return BottomSheetThemeData(
      backgroundColor: c.surfaceContainerHigh,
      surfaceTintColor: c.surfaceTint,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      dragHandleColor: c.onSurfaceVariant,
      showDragHandle: true,
    );
  }

  static SnackBarThemeData _snackBarTheme(ColorScheme c, TextTheme t, BorderRadius br) {
    return SnackBarThemeData(
      backgroundColor: c.inverseSurface,
      contentTextStyle: t.bodyMedium?.copyWith(color: c.onInverseSurface),
      actionTextColor: c.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: br),
    );
  }

  static MaterialBannerThemeData _bannerTheme(ColorScheme c, TextTheme t) {
    return MaterialBannerThemeData(
      backgroundColor: c.surfaceContainerHigh,
      contentTextStyle: t.bodyMedium,
    );
  }

  static ChipThemeData _chipTheme(ColorScheme c, TextTheme t) {
    return ChipThemeData(
      backgroundColor: c.surfaceContainerHighest,
      deleteIconColor: c.onSurfaceVariant,
      disabledColor: c.onSurface.withValues(alpha: 0.12),
      selectedColor: c.secondaryContainer,
      secondarySelectedColor: c.tertiaryContainer,
      labelStyle: t.labelLarge,
      secondaryLabelStyle: t.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: c.outline),
    );
  }

  // -- Buttons

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme c, TextTheme t, OutlinedBorder s) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: s,
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        textStyle: t.labelLarge,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme c, TextTheme t, OutlinedBorder s) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: s,
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        textStyle: t.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme c, TextTheme t, OutlinedBorder s) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: s,
        foregroundColor: c.primary,
        side: BorderSide(color: c.outline),
        textStyle: t.labelLarge,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme c, TextTheme t) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        foregroundColor: c.primary,
        textStyle: t.labelLarge,
      ),
    );
  }

  static SegmentedButtonThemeData _segmentedButtonTheme() {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  static IconButtonThemeData _iconButtonTheme(ColorScheme c) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.onSurfaceVariant,
        highlightColor: c.primary.withValues(alpha: 0.12),
      ),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme(ColorScheme c) {
    return FloatingActionButtonThemeData(
      backgroundColor: c.primaryContainer,
      foregroundColor: c.onPrimaryContainer,
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // -- Inputs

  static InputDecorationTheme _inputDecorationTheme(ColorScheme c, TextTheme t, BorderRadius br) {
    return InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: br, borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: br, borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: br, borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: br, borderSide: BorderSide(color: c.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: br, borderSide: BorderSide(color: c.error, width: 2),
      ),
      labelStyle: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
      hintStyle: t.bodyLarge?.copyWith(
        color: c.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      floatingLabelStyle: t.bodySmall?.copyWith(color: c.primary),
    );
  }

  static DropdownMenuThemeData _dropdownMenuTheme(TextTheme t, BorderRadius br) {
    return DropdownMenuThemeData(
      textStyle: t.bodyLarge,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.bodyLarge?.color,
        border: OutlineInputBorder(borderRadius: br),
      ),
    );
  }

  static SearchBarThemeData _searchBarTheme(ColorScheme c, TextTheme t) {
    return SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(c.surfaceContainerHighest),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(t.bodyLarge),
      hintStyle: WidgetStatePropertyAll(t.bodyLarge?.copyWith(color: c.onSurfaceVariant)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }

  static SearchViewThemeData _searchViewTheme(ColorScheme c, TextTheme t) {
    return SearchViewThemeData(
      backgroundColor: c.surfaceContainerHigh,
      headerTextStyle: t.titleMedium,
      headerHintStyle: t.bodyLarge,
    );
  }

  // -- Selection

  static CheckboxThemeData _checkboxTheme(ColorScheme c) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.primary
          : c.surfaceContainerHighest;
      }),
      checkColor: WidgetStatePropertyAll(c.onPrimary),
      side: BorderSide(color: c.outline, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  static RadioThemeData _radioTheme(ColorScheme c) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.primary
          : c.onSurfaceVariant;
      }),
    );
  }

  static SwitchThemeData _switchTheme(ColorScheme c) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.onPrimary
          : c.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.primary
          : c.surfaceContainerHighest;
      }),
    );
  }

  static SliderThemeData _sliderTheme(ColorScheme c, TextTheme t) {
    return SliderThemeData(
      activeTrackColor: c.primary,
      inactiveTrackColor: c.surfaceContainerHighest,
      thumbColor: c.primary,
      overlayColor: c.primary.withValues(alpha: 0.12),
      valueIndicatorColor: c.inverseSurface,
      valueIndicatorTextStyle: t.labelMedium?.copyWith(color: c.onInverseSurface),
    );
  }

  static ProgressIndicatorThemeData _progressIndicatorTheme(ColorScheme c) {
    return ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceContainerHighest,
      circularTrackColor: c.surfaceContainerHighest,
    );
  }

  // -- Lists

  static ListTileThemeData _listTileTheme(ColorScheme c, TextTheme t, BorderRadius br) {
    return ListTileThemeData(
      iconColor: c.onSurfaceVariant,
      textColor: c.onSurface,
      tileColor: Colors.transparent,
      selectedTileColor: c.secondaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: br),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: t.bodyLarge,
      subtitleTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
    );
  }

  static ExpansionTileThemeData _expansionTileTheme(ColorScheme c, TextTheme t, BorderRadius br) {
    return ExpansionTileThemeData(
      backgroundColor: c.surfaceContainerLow,
      collapsedBackgroundColor: c.surface,
      iconColor: c.onSurfaceVariant,
      collapsedIconColor: c.onSurfaceVariant,
      textColor: c.onSurface,
      collapsedTextColor: c.onSurface,
      shape: RoundedRectangleBorder(borderRadius: br),
      collapsedShape: RoundedRectangleBorder(borderRadius: br),
    );
  }

  // -- Menus

  static PopupMenuThemeData _popupMenuTheme(ColorScheme c, TextTheme t, BorderRadius br) {
    return PopupMenuThemeData(
      color: c.surfaceContainer,
      surfaceTintColor: c.surfaceTint,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: br),
      textStyle: t.bodyLarge,
    );
  }

  static MenuThemeData _menuTheme(ColorScheme c, BorderRadius br) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
        surfaceTintColor: WidgetStatePropertyAll(c.surfaceTint),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: br)),
      ),
    );
  }

  static MenuBarThemeData _menuBarTheme(ColorScheme c) {
    return MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
        elevation: const WidgetStatePropertyAll(2),
      ),
    );
  }

  // -- Pickers

  static TabBarThemeData _tabBarTheme(ColorScheme c, TextTheme t) {
    return TabBarThemeData(
      labelColor: c.primary,
      unselectedLabelColor: c.onSurfaceVariant,
      indicatorColor: c.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: t.titleSmall,
      unselectedLabelStyle: t.titleSmall,
      dividerColor: c.outlineVariant,
    );
  }

  static TooltipThemeData _tooltipTheme(ColorScheme c, TextTheme t) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: c.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: t.bodySmall?.copyWith(color: c.onInverseSurface),
    );
  }

  static DatePickerThemeData _datePickerTheme(ColorScheme c, TextTheme t) {
    return DatePickerThemeData(
      backgroundColor: c.surfaceContainerHigh,
      headerBackgroundColor: c.primaryContainer,
      headerForegroundColor: c.onPrimaryContainer,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.onPrimary : c.onSurface;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.primary : null;
      }),
      todayForegroundColor: WidgetStatePropertyAll(c.primary),
      todayBackgroundColor: WidgetStatePropertyAll(
        c.primaryContainer.withValues(alpha: 0.4),
      ),
    );
  }

  static TimePickerThemeData _timePickerTheme(ColorScheme c) {
    return TimePickerThemeData(
      backgroundColor: c.surfaceContainerHigh,
      hourMinuteColor: c.surfaceContainerHighest,
      hourMinuteTextColor: c.onSurface,
      dialBackgroundColor: c.primaryContainer,
      dialHandColor: c.primary,
      entryModeIconColor: c.onSurfaceVariant,
    );
  }

  // -- Misc

  static BadgeThemeData _badgeTheme(ColorScheme c, TextTheme t) {
    return BadgeThemeData(
      backgroundColor: c.error,
      textColor: c.onError,
      textStyle: t.labelSmall,
    );
  }

  static DividerThemeData _dividerTheme(ColorScheme c) {
    return DividerThemeData(
      color: c.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  static DataTableThemeData _dataTableTheme(ColorScheme c, TextTheme t) {
    return DataTableThemeData(
      headingTextStyle: t.titleSmall?.copyWith(color: c.onSurfaceVariant),
      dataTextStyle: t.bodyMedium,
      headingRowColor: WidgetStatePropertyAll(c.surfaceContainerHighest),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.outlineVariant)),
      ),
    );
  }

  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppPalette.seed,
      brightness: Brightness.light,
      primary: AppPalette.seed,
      secondary: AppPalette.secondarySeed,
      tertiary: AppPalette.tertiarySeed,
      error: AppPalette.error,
    );
  }

  static ColorScheme darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppPalette.seed,
      brightness: Brightness.dark,
      primary: AppPalette.surfaceTintDark,
      secondary: AppPalette.secondarySeed,
      tertiary: AppPalette.tertiarySeed,
      error: AppPalette.errorDark,
    );
  }
}
