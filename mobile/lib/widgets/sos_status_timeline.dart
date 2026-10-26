import 'package:flutter/material.dart';

import '../data/models/sos.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Suivi d'un SOS en 3 étapes (prototype : `.tl` `.step`). Une étape qui se coche passe en fondu.
class SosStatusTimeline extends StatelessWidget {
  const SosStatusTimeline({super.key, required this.etapes});

  final List<EtapeSos> etapes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, etape) in etapes.indexed)
          _Step(
            etape: etape,
            // Étape à venir : ni faite, ni immédiatement après une étape faite.
            aVenir: !etape.fait && i > 0 && !etapes[i - 1].fait,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.etape, required this.aVenir});

  final EtapeSos etape;
  final bool aVenir;

  static const _fondu = Duration(milliseconds: 300);
  static const double _hauteurLigneTitre = 16 * 1.21 / 14;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: HydroticSpacing.gapM),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HydroticColors.slateXLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: _fondu,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: etape.fait ? HydroticColors.slate : HydroticColors.white,
              border: Border.all(
                color: etape.fait ? HydroticColors.slate : HydroticColors.slateLight,
                width: 2,
              ),
            ),
            child: AnimatedOpacity(
              duration: _fondu,
              opacity: etape.fait ? 1 : 0,
              child: const Icon(Icons.check_rounded, size: 14, color: HydroticColors.white),
            ),
          ),
          const SizedBox(width: HydroticSpacing.gapL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etape.etape,
                  style: HydroticText.button.copyWith(
                    color: aVenir ? HydroticColors.grayLight : HydroticColors.gray,
                    // Prototype : titre 14 px dans une ligne de 16 px (taille par défaut du parent).
                    height: _hauteurLigneTitre,
                    leadingDistribution: TextLeadingDistribution.proportional,
                  ),
                ),
                if (etape.detail.isNotEmpty)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: etape.fait ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        etape.detail,
                        style: HydroticText.small.copyWith(color: HydroticColors.grayLight),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
