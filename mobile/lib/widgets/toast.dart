import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Message bref en bas d'écran (ex. « Disponible dans une prochaine version »).
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: HydroticColors.gray,
      margin: const EdgeInsets.fromLTRB(
        HydroticSpacing.screenPadding,
        0,
        HydroticSpacing.screenPadding,
        HydroticSizes.bottomNav + HydroticSpacing.gapL,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HydroticRadius.button)),
      content: Text(message, style: HydroticText.body.copyWith(color: HydroticColors.white)),
    ));
}
