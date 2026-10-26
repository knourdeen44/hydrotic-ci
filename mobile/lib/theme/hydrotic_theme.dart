import 'package:flutter/material.dart';

import 'hydrotic_colors.dart';
import 'hydrotic_text.dart';

/// Thème Material 3 construit à partir des fichiers générés (aucune valeur en dur ici).
abstract final class HydroticTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: HydroticColors.slate,
      onPrimary: HydroticColors.white,
      secondary: HydroticColors.slateDark,
      onSecondary: HydroticColors.white,
      secondaryContainer: HydroticColors.slateLight,
      onSecondaryContainer: HydroticColors.slateDark,
      tertiary: HydroticColors.deep,
      onTertiary: HydroticColors.white,
      surface: HydroticColors.white,
      onSurface: HydroticColors.gray,
      onSurfaceVariant: HydroticColors.grayLight,
      surfaceContainerLow: HydroticColors.slateXLight,
      outline: HydroticColors.slateLight,
      outlineVariant: HydroticColors.slateLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: HydroticText.fontFamily,
      scaffoldBackgroundColor: HydroticColors.white,
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(HydroticColors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? HydroticColors.slate : HydroticColors.slateLight,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: HydroticColors.slate),
      textTheme: const TextTheme(
        headlineSmall: HydroticText.screenTitle,
        titleLarge: HydroticText.sheetTitle,
        titleMedium: HydroticText.greeting,
        titleSmall: HydroticText.sectionTitle,
        bodyMedium: HydroticText.body,
        bodySmall: HydroticText.caption,
        labelLarge: HydroticText.button,
        labelSmall: HydroticText.small,
      ).apply(bodyColor: HydroticColors.gray, displayColor: HydroticColors.gray),
    );
  }
}
