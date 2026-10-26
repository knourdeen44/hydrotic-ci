import 'package:flutter/material.dart';

import '../../data/models/sos.dart';
import '../../l10n/fr.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/sos_status_timeline.dart';

/// État « SOS envoyé » (prototype : `.sent`, `.okc`, `.tl`).
class SosSentView extends StatelessWidget {
  const SosSentView({super.key, required this.etapes, required this.afficherInfo});

  static const double _margeTextes = 10;
  static const double _margeBlocs = HydroticSpacing.sheetPadding - _margeTextes;

  final List<EtapeSos> etapes;

  /// Bloc « Les secours sont informés » (apparaît après la prise en charge).
  final bool afficherInfo;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HydroticColors.white,
      child: SingleChildScrollView(
        // Marge du prototype : 18 px. Les textes centrés disposent de 8 px de plus de chaque côté :
        // Flutter rend l'Inter en 12 px ≈ 4 % plus large que le navigateur, et la phrase
        // « Restez en hauteur… » passerait sinon sur deux lignes (une seule dans la maquette).
        padding: const EdgeInsets.symmetric(vertical: HydroticSpacing.sheetPadding, horizontal: _margeTextes),
        child: Column(
          children: [
            const SizedBox(height: 28),
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: HydroticColors.statusRecuBg, shape: BoxShape.circle),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: HydroticColors.riskRouge, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 28, color: HydroticColors.white),
              ),
            ),
            const SizedBox(height: HydroticSpacing.gapL),
            Text(Fr.sosEnvoye, style: HydroticText.screenTitle.copyWith(color: HydroticColors.gray)),
            const SizedBox(height: 4),
            Text(
              Fr.restezEnHauteur,
              textAlign: TextAlign.center,
              style: HydroticText.caption.copyWith(color: HydroticColors.grayLight),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _margeBlocs),
              child: SosStatusTimeline(etapes: etapes),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _margeBlocs),
              child: AnimatedOpacity(
                opacity: afficherInfo ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: HydroticColors.slateXLight,
                    borderRadius: BorderRadius.circular(HydroticRadius.chip),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Fr.secoursInformes,
                        style: HydroticText.button.copyWith(
                          color: HydroticColors.slateDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        Fr.positionMiseAJour,
                        style: HydroticText.caption.copyWith(
                          color: HydroticColors.gray,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
