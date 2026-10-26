import 'package:flutter/material.dart';

import '../../l10n/fr.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/switch_row.dart';

/// Gabarit d'une étape du démarrage : flèche retour, titre (sur plusieurs lignes si besoin),
/// contenu puis bouton. Marge basse réservée au bouton SOS.
class DemarrageEtape extends StatelessWidget {
  const DemarrageEtape({
    super.key,
    required this.titre,
    required this.children,
    required this.bouton,
    this.onBack,
  });

  final String titre;
  final List<Widget> children;
  final Widget bouton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final retour = onBack;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HydroticSpacing.headerPaddingX,
        4,
        HydroticSpacing.headerPaddingX,
        HydroticSizes.sosFab + 32,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: retour == null
              ? const SizedBox(height: HydroticSizes.touchTarget)
              : IconButton(
                  onPressed: retour,
                  tooltip: Fr.retour,
                  icon: const Icon(Icons.arrow_back_rounded, color: HydroticColors.gray),
                ),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(titre, style: HydroticText.screenTitle.copyWith(color: HydroticColors.gray)),
        ),
        const SizedBox(height: HydroticSpacing.dashGap),
        ...children,
        const SizedBox(height: HydroticSpacing.dashGap),
        bouton,
      ],
    );
  }
}

/// Carte explicative avec interrupteur simulé (étape « Autorisations »).
class CarteAutorisation extends StatelessWidget {
  const CarteAutorisation({
    super.key,
    required this.icon,
    required this.titre,
    required this.texte,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String titre;
  final String texte;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: HydroticColors.slateXLight,
        borderRadius: BorderRadius.circular(HydroticRadius.mini),
      ),
      child: SwitchRow(icon: icon, titre: titre, description: texte, value: value, onChanged: onChanged),
    );
  }
}
