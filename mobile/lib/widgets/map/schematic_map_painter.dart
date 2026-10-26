import 'package:flutter/material.dart';

import '../../data/models/niveau_risque.dart';
import '../../data/models/point_svg.dart';
import '../../data/models/signalement.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_text.dart';
import '../../theme/risk_colors.dart';
import 'schematic_map_decor.dart';
import 'svg_path.dart';

/// Zone à dessiner, avec son niveau avant et après la dernière transition.
typedef ZoneDessin = ({String contour, NiveauRisque avant, NiveauRisque apres});

/// Dessine la carte schématique dans le repère SVG 340 × 700.
class SchematicMapPainter extends CustomPainter {
  SchematicMapPainter({
    required this.zones,
    required this.signalements,
    required this.positionVous,
    required this.signalementActifId,
    required this.tronconsAvant,
    required this.tronconsApres,
    required this.transition,
    required this.pop,
    required this.pulse,
  }) : super(repaint: Listenable.merge([transition, pop, pulse]));

  final List<ZoneDessin> zones;
  final List<Signalement> signalements;
  final PointSvg? positionVous;
  final String? signalementActifId;

  /// Tronçons surlignés en rouge (identifiants de signalement) avant / après la transition.
  final Set<String> tronconsAvant;
  final Set<String> tronconsApres;

  /// Fondu des couleurs de zone et des tronçons (0 → 1).
  final Animation<double> transition;

  /// Échelle d'apparition du signalement actif.
  final Animation<double> pop;

  /// Pulsation du signalement actif (0 → 1).
  final Animation<double> pulse;

  static final _paths = <String, Path>{};
  static Path _path(String data) => _paths.putIfAbsent(data, () => parseSvgPath(data));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / mapViewBoxWidth, size.height / mapViewBoxHeight);
    final t = transition.value;

    canvas.drawPath(_path(mapWaterPath), Paint()..color = HydroticColors.mapWater);
    for (final (road, width) in mapRoads) {
      canvas.drawPath(
        _path(road),
        Paint()
          ..color = HydroticColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }

    for (final zone in zones) {
      final path = _path(zone.contour);
      canvas.drawPath(
        path,
        Paint()..color = Color.lerp(zone.avant.remplissageZone, zone.apres.remplissageZone, t)!,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(zone.avant.couleur, zone.apres.couleur, t)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    for (final s in signalements) {
      final troncon = s.svgTroncon;
      if (troncon == null) continue;
      final avant = tronconsAvant.contains(s.id) ? 1.0 : 0.0;
      final apres = tronconsApres.contains(s.id) ? 1.0 : 0.0;
      final opacite = avant + (apres - avant) * t;
      if (opacite == 0) continue;
      canvas.drawPath(
        _path(troncon),
        Paint()
          ..color = HydroticColors.riskRouge.withValues(alpha: opacite)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final s in signalements) {
      final c = Offset(s.position.x, s.position.y);
      if (s.id == signalementActifId) {
        _paintActif(canvas, c);
      } else {
        canvas.drawCircle(c, 9, Paint()..color = HydroticColors.slate);
        canvas.drawCircle(
          c,
          9,
          Paint()
            ..color = HydroticColors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }

    final vous = positionVous;
    if (vous != null) {
      final c = Offset(vous.x, vous.y);
      canvas.drawCircle(c, 22, Paint()..color = HydroticColors.slate.withValues(alpha: .18));
      canvas.drawCircle(c, 8, Paint()..color = HydroticColors.deep);
      canvas.drawCircle(
        c,
        8,
        Paint()
          ..color = HydroticColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    for (final s in signalements) {
      final etiquette = s.svgEtiquette;
      if (etiquette == null) continue;
      _text(
        canvas,
        s.rue,
        HydroticText.small.copyWith(color: HydroticColors.gray, fontWeight: FontWeight.w700),
        // Le y du SVG est la ligne de base du texte.
        Offset(etiquette.x, etiquette.y - 11),
      );
    }
  }

  void _paintActif(Canvas canvas, Offset c) {
    final p = pulse.value;
    if (p > 0 && p < 1) {
      final rayon = 15 * (.6 + 1.8 * p);
      final alpha = .35 * .8 * (1 - p);
      canvas.drawCircle(c, rayon, Paint()..color = HydroticColors.riskRouge.withValues(alpha: alpha));
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(pop.value);
    canvas.drawCircle(Offset.zero, 15, Paint()..color = HydroticColors.riskRouge);
    final style = HydroticText.button.copyWith(color: HydroticColors.white, fontSize: 13);
    _text(canvas, '!', style, Offset.zero, centre: true);
    canvas.restore();
  }

  void _text(Canvas canvas, String text, TextStyle style, Offset at, {bool centre = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final origin = centre ? at - Offset(painter.width / 2, painter.height / 2) : at;
    painter.paint(canvas, origin);
    painter.dispose();
  }

  @override
  bool shouldRepaint(SchematicMapPainter oldDelegate) => true;
}
