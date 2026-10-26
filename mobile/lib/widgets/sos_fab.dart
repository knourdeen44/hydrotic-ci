import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Bouton SOS flottant (prototype : `.sosfab`), présent sur tous les écrans sauf l'écran SOS.
class SosFab extends StatelessWidget {
  const SosFab({super.key, required this.onPressed});

  /// Marge depuis le bord droit de l'écran.
  static const double right = 18;

  /// Écart au-dessus de la barre de navigation.
  static const double gapAboveNav = 16;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: Fr.sosSemantique,
      excludeSemantics: true,
      child: Container(
        width: HydroticSizes.sosFab,
        height: HydroticSizes.sosFab,
        decoration: const BoxDecoration(
          color: HydroticColors.riskRouge,
          shape: BoxShape.circle,
          boxShadow: HydroticShadows.sos,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Text(
                Fr.sos,
                style: HydroticText.statValue.copyWith(
                  color: HydroticColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
