import 'package:flutter/material.dart';
import 'package:material_3_demo/material_3_demo.dart';

import '../../../core/app_theme.dart';

/// Full-screen Material 3 component catalog themed exclusively with [AppTheme].
class ThemePreviewView extends StatelessWidget {
  const ThemePreviewView({super.key, this.brightness});

  /// When null, [brightness] is taken from the enclosing [Theme] (e.g. app
  /// [MaterialApp]) so light/dark tracks [ThemeMode].
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final Brightness resolvedBrightness =
        brightness ?? Theme.of(context).brightness;
    final ThemeData previewTheme = AppTheme.forBrightness(resolvedBrightness);

    return Material3DemoPreview(theme: previewTheme);
  }
}
