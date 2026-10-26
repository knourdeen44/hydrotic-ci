import 'package:flutter/material.dart';

import '../data/models/niveau_risque.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_text.dart';
import '../theme/risk_colors.dart';
import 'hydrotic_sheet.dart';

/// Feuille des consignes numérotées (prototype : `.cons`), pastilles à la couleur du niveau.
class ConsignesSheet extends StatelessWidget {
  const ConsignesSheet({
    super.key,
    required this.titre,
    required this.sousTitre,
    required this.consignes,
    required this.niveau,
    this.animate = true,
  });

  final String titre;
  final String sousTitre;
  final List<String> consignes;
  final NiveauRisque niveau;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return HydroticSheet(
      animate: animate,
      bottomPadding: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: HydroticText.sheetTitle.copyWith(color: HydroticColors.gray)),
          const SizedBox(height: 6),
          Text(sousTitre, style: HydroticText.caption.copyWith(color: HydroticColors.grayLight)),
          const SizedBox(height: 14),
          for (final (i, consigne) in consignes.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: niveau.couleur, shape: BoxShape.circle),
                    child: Text(
                      '${i + 1}',
                      style: HydroticText.caption.copyWith(
                        color: HydroticColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(consigne, style: HydroticText.body.copyWith(color: HydroticColors.gray)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
