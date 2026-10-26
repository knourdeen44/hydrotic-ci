import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Bouton à contour pointillé (prototype : `.smsbtn`, bordure 1,5 px slate, rayon 12).
class DashedButton extends StatelessWidget {
  const DashedButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HydroticRadius.legend);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: CustomPaint(
        painter: const _DashedBorderPainter(),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: HydroticSizes.touchTarget),
              child: Padding(
                padding: const EdgeInsets.all(HydroticSpacing.gapM),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: HydroticText.caption.copyWith(
                      color: HydroticColors.slateDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  static const double _trait = 5;
  static const double _espace = 4;

  @override
  void paint(Canvas canvas, Size size) {
    const largeur = 1.5;
    final rect = (Offset.zero & size).deflate(largeur / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(HydroticRadius.legend)));
    final paint = Paint()
      ..color = HydroticColors.slate
      ..style = PaintingStyle.stroke
      ..strokeWidth = largeur;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _trait + _espace) {
        canvas.drawPath(metric.extractPath(d, d + _trait), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
