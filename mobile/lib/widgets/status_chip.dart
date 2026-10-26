import 'package:flutter/material.dart';

import '../data/models/sos.dart';
import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Statut d'un SOS : Reçu / En route / Secouru (prototype : `.st.r/.e/.s`).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.statut, this.onTap});

  final StatutSos statut;

  /// Appui : fait avancer le statut (état local).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, fond, texte) = switch (statut) {
      StatutSos.recu => (Fr.statutRecu, HydroticColors.statusRecuBg, HydroticColors.statusRecuFg),
      StatutSos.enRoute => (Fr.statutEnRoute, HydroticColors.statusEnRouteBg, HydroticColors.statusEnRouteFg),
      StatutSos.secouru => (Fr.statutSecouru, HydroticColors.statusSecouruBg, HydroticColors.statusSecouruFg),
    };
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          decoration: BoxDecoration(
            color: fond,
            borderRadius: BorderRadius.circular(HydroticRadius.dashChip),
          ),
          child: Text(label, style: HydroticText.small.copyWith(color: texte, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
