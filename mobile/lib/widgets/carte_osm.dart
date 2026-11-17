import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/models/geo.dart';
import '../data/models/niveau_risque.dart';
import '../data/models/signalement.dart';
import '../data/models/zone.dart';
import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/risk_colors.dart';
import 'schematic_map.dart';

/// Carte réelle (mode réel) : fond OpenStreetMap, contours OSM des quartiers, signalements, position.
class CarteOsm extends StatelessWidget {
  const CarteOsm({
    super.key,
    required this.zones,
    this.signalements = const [],
    this.vous,
    this.signalementActifId,
    this.interactive = true,
    this.centre,
    this.legende = true,
  });

  final List<({Zone zone, NiveauRisque niveau})> zones;
  final List<Signalement> signalements;
  final Geo? vous;
  final String? signalementActifId;
  final bool interactive;

  /// Centre sans position connue (ex. quartier principal) ; sinon, tous les quartiers sont cadrés.
  final Geo? centre;
  final bool legende;

  static const _abidjan = LatLng(5.33, -3.98);

  static LatLng _point(Geo g) => LatLng(g.lat, g.lon);

  @override
  Widget build(BuildContext context) {
    final contours = [for (final z in zones) for (final anneau in z.zone.contour) for (final g in anneau) _point(g)];
    final vous = this.vous;
    final centre = vous ?? this.centre;
    final carte = FlutterMap(
      // Recentrée quand la position arrive (le centre initial n'est lu qu'à la création).
      key: ValueKey(centre),
      options: MapOptions(
        initialCenter: centre == null ? _abidjan : _point(centre),
        initialZoom: 15,
        initialCameraFit: centre == null && contours.length > 2
            ? CameraFit.bounds(bounds: LatLngBounds.fromPoints(contours), padding: const EdgeInsets.all(24))
            : null,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ci.hydrotic.app',
        ),
        PolygonLayer(polygons: [
          for (final z in zones)
            for (final anneau in z.zone.contour)
              Polygon(
                points: [for (final g in anneau) _point(g)],
                color: z.niveau.couleur.withValues(alpha: .22),
                borderColor: z.niveau.couleur,
                borderStrokeWidth: 2,
              ),
        ]),
        MarkerLayer(markers: [
          for (final s in signalements)
            if (s.geo case final geo?)
              Marker(
                point: _point(geo),
                width: s.id == signalementActifId ? 22 : 16,
                height: s.id == signalementActifId ? 22 : 16,
                child: _Carre(
                  couleur: s.statut == StatutSignalement.confirme ? HydroticColors.riskRouge : HydroticColors.slate,
                ),
              ),
          if (vous != null) Marker(point: _point(vous), width: 18, height: 18, child: const _Vous()),
        ]),
        const SimpleAttributionWidget(source: Text(Fr.attributionOsm)),
      ],
    );
    if (!legende) return carte;
    return Stack(
      fit: StackFit.expand,
      children: [carte, const Positioned(top: 10, left: 10, child: CarteLegende(niveaux: true))],
    );
  }
}

/// Signalement : carré (comme sur la carte schématique).
class _Carre extends StatelessWidget {
  const _Carre({required this.couleur});

  final Color couleur;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: couleur,
          border: Border.all(color: HydroticColors.white, width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
      );
}

/// Position de l'habitant.
class _Vous extends StatelessWidget {
  const _Vous();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: HydroticColors.deep,
          shape: BoxShape.circle,
          border: Border.all(color: HydroticColors.white, width: 3),
        ),
      );
}
