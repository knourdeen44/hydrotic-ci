import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// En-tête de l'accueil (prototype : `.top`).
class HydroticHeader extends StatelessWidget {
  const HydroticHeader({
    super.key,
    required this.prenom,
    required this.quartier,
    required this.nbZones,
    this.onZonesTap,
    this.onLogoLongPress,
  });

  final String prenom;
  final String quartier;
  final int nbZones;

  /// Appui sur la puce « 2 zones » : sélecteur de zone.
  final VoidCallback? onZonesTap;

  /// Appui long sur le logo : menu du mode démo.
  final VoidCallback? onLogoLongPress;

  @override
  Widget build(BuildContext context) {
    // Prototype : marges 6/18/12 et ligne de 34 px. La ligne passe à 44 px (zone tactile de la puce)
    // et les marges haute/basse perdent 5 px chacune : même hauteur totale, même position visuelle.
    const extra = (HydroticSizes.touchTarget - HydroticSizes.avatarLogo) / 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HydroticSpacing.headerPaddingX,
        6.0 - extra,
        HydroticSpacing.headerPaddingX,
        12.0 - extra,
      ),
      child: SizedBox(
        height: HydroticSizes.touchTarget,
        child: Row(
          children: [
            GestureDetector(
              onLongPress: onLogoLongPress,
              child: Image.asset(
                'assets/images/logo_hydrotic_icon.png',
                width: HydroticSizes.avatarLogo,
                height: HydroticSizes.avatarLogo,
                fit: BoxFit.contain,
                semanticLabel: 'Hydrotic CI',
              ),
            ),
            const SizedBox(width: HydroticSpacing.gapM),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Fr.bonjour(prenom),
                    style: HydroticText.greeting.copyWith(color: HydroticColors.gray),
                  ),
                  Text(
                    quartier,
                    style: HydroticText.caption.copyWith(color: HydroticColors.grayLight),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              child: InkWell(
                onTap: onZonesTap,
                borderRadius: BorderRadius.circular(HydroticRadius.chip),
                child: SizedBox(
                  height: HydroticSizes.touchTarget,
                  child: Center(child: _ZonesChip(label: Fr.nbZones(nbZones))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZonesChip extends StatelessWidget {
  const _ZonesChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
      decoration: BoxDecoration(
        color: HydroticColors.slateLight,
        borderRadius: BorderRadius.circular(HydroticRadius.chip),
      ),
      child: Text(
        label,
        style: HydroticText.small.copyWith(
          color: HydroticColors.slateDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
