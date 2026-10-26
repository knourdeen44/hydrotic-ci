import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models/risque.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Barres de pluie sur 7 jours (prototype : `.bars` + `.lbl`). Prévisions hachurées.
class RainBars extends StatelessWidget {
  const RainBars({super.key, required this.jours, this.height = HydroticSizes.rainBars});

  final List<PluieJour> jours;
  final double height;

  /// La barre la plus haute occupe 92 % de la hauteur (valeurs du prototype).
  static const double _remplissageMax = .92;

  @override
  Widget build(BuildContext context) {
    final max = jours.map((j) => j.mm).fold<double>(0, math.max);
    final resume = jours.map((j) => '${j.label} ${j.mm.round()} mm').join(', ');
    return Semantics(
      label: resume,
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, jour) in jours.indexed) ...[
                  if (i > 0) const SizedBox(width: HydroticSpacing.gapS),
                  Expanded(
                    child: FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: max == 0 ? 0.0 : jour.mm / max * _remplissageMax,
                      child: _Bar(prevision: jour.prevision),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final (i, jour) in jours.indexed) ...[
                if (i > 0) const SizedBox(width: HydroticSpacing.gapS),
                Expanded(
                  child: Text(
                    jour.label,
                    textAlign: TextAlign.center,
                    style: HydroticText.navLabel.copyWith(color: HydroticColors.grayLight),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.prevision});

  final bool prevision;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: prevision
          ? const CustomPaint(painter: _HatchPainter(), child: SizedBox.expand())
          : const ColoredBox(color: HydroticColors.slate, child: SizedBox.expand()),
    );
  }
}

/// Hachures à 45° : bandes de 4 px slate / slateLight (repeating-linear-gradient du prototype).
class _HatchPainter extends CustomPainter {
  const _HatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = HydroticColors.slateLight);
    final paint = Paint()
      ..color = HydroticColors.slate
      ..strokeWidth = 4;
    // Lignes orientées « \ », espacées de 8 px perpendiculairement.
    const step = 8 * math.sqrt2;
    for (var c = -size.width; c < size.height + size.width; c += step) {
      canvas.drawLine(Offset(0, c), Offset(size.width, c + size.width), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => false;
}
