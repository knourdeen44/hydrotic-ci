import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Titre d'écran (20/800) avec flèche retour facultative. Même hauteur que l'en-tête de l'accueil.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.titre, this.onBack});

  final String titre;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final retour = onBack;
    return Padding(
      padding: EdgeInsets.fromLTRB(retour == null ? HydroticSpacing.headerPaddingX : 4, 4, HydroticSpacing.headerPaddingX, 4),
      child: SizedBox(
        height: HydroticSizes.touchTarget,
        child: Row(
          children: [
            if (retour != null)
              IconButton(
                onPressed: retour,
                tooltip: Fr.retour,
                icon: const Icon(Icons.arrow_back_rounded, color: HydroticColors.gray),
              ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HydroticText.screenTitle.copyWith(color: HydroticColors.gray),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
