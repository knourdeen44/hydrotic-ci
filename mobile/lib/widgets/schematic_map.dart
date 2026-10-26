import 'package:flutter/material.dart';

import '../data/models/niveau_risque.dart';
import '../data/models/point_svg.dart';
import '../data/models/signalement.dart';
import '../data/models/zone.dart';
import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';
import 'map/schematic_map_decor.dart';
import 'map/schematic_map_painter.dart';

/// Zone affichée sur la carte avec son niveau courant.
typedef ZoneCarte = ({Zone zone, NiveauRisque niveau});

/// Carte schématique en SVG (prototype : `.map`). Pas de vraie carte en phase 1.
/// Un changement de niveau de zone ou de tronçon confirmé passe en fondu (600 ms).
class SchematicMap extends StatefulWidget {
  const SchematicMap({
    super.key,
    required this.zones,
    required this.signalements,
    this.positionVous,
    this.signalementActifId,
    this.tronconsConfirmes = const {},
    this.showLegend = true,
    this.animateActif = true,
    this.alignment = Alignment.topCenter,
  });

  final List<ZoneCarte> zones;
  final List<Signalement> signalements;
  final PointSvg? positionVous;

  /// Signalement mis en avant (rouge avec « ! », animation « pop » + pulsation).
  final String? signalementActifId;

  /// Signalements dont le tronçon est surligné en rouge.
  final Set<String> tronconsConfirmes;
  final bool showLegend;
  final bool animateActif;

  /// Partie du repère 340 × 700 gardée visible quand la carte est plus petite (mini-carte).
  final Alignment alignment;

  @override
  State<SchematicMap> createState() => _SchematicMapState();
}

class _SchematicMapState extends State<SchematicMap> with TickerProviderStateMixin {
  late final _transition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: 1,
  );

  // Pop (0 → 450 ms) puis pulsation (200 → 1 600 ms), comme dans le prototype.
  late final _actif = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final _pop = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 70),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
  ]).animate(CurvedAnimation(parent: _actif, curve: const Interval(0, .28, curve: Curves.ease)));
  late final _pulse = CurvedAnimation(parent: _actif, curve: const Interval(.125, 1, curve: Curves.easeOut));

  late Map<String, NiveauRisque> _niveauxAvant = _niveaux(widget.zones);
  late Set<String> _tronconsAvant = widget.tronconsConfirmes;

  static Map<String, NiveauRisque> _niveaux(List<ZoneCarte> zones) =>
      {for (final z in zones) z.zone.id: z.niveau};

  @override
  void initState() {
    super.initState();
    if (widget.signalementActifId == null) return;
    if (widget.animateActif) {
      _actif.forward();
    } else {
      _actif.value = 1;
    }
  }

  @override
  void didUpdateWidget(SchematicMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final avant = _niveaux(oldWidget.zones);
    final changement = widget.zones.any((z) => avant[z.zone.id] != z.niveau) ||
        !_memes(oldWidget.tronconsConfirmes, widget.tronconsConfirmes);
    if (changement) {
      _niveauxAvant = avant;
      _tronconsAvant = oldWidget.tronconsConfirmes;
      _transition.forward(from: 0);
    }
    if (widget.signalementActifId != oldWidget.signalementActifId && widget.signalementActifId != null) {
      _actif.forward(from: widget.animateActif ? 0.0 : 1.0);
    }
  }

  static bool _memes(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

  @override
  void dispose() {
    _transition.dispose();
    _actif.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = SchematicMapPainter(
      zones: [
        for (final z in widget.zones)
          (contour: z.zone.svgMobile, avant: _niveauxAvant[z.zone.id] ?? z.niveau, apres: z.niveau),
      ],
      signalements: widget.signalements,
      positionVous: widget.positionVous,
      signalementActifId: widget.signalementActifId,
      tronconsAvant: _tronconsAvant,
      tronconsApres: widget.tronconsConfirmes,
      transition: _transition,
      pop: _pop,
      pulse: _pulse,
    );
    return ColoredBox(
      color: HydroticColors.mapBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: widget.alignment,
              child: SizedBox(
                width: mapViewBoxWidth,
                height: mapViewBoxHeight,
                child: CustomPaint(painter: painter),
              ),
            ),
          ),
          if (widget.showLegend) const Positioned(top: 10, left: 10, child: _Legend()),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: HydroticColors.white,
        borderRadius: BorderRadius.circular(HydroticRadius.legend),
        boxShadow: HydroticShadows.legend,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendItem(color: HydroticColors.riskRouge, label: Fr.legendeInonde),
          _LegendItem(color: HydroticColors.slate, label: Fr.legendeSignalement),
          _LegendItem(color: HydroticColors.deep, label: Fr.legendeVous),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: HydroticText.navLabel.copyWith(height: 1.7, color: HydroticColors.gray)),
      ],
    );
  }
}
