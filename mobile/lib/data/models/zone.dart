import 'geo.dart';

/// Quartier suivi (diagramme UML : Zone).
class Zone {
  const Zone({
    required this.id,
    required this.nom,
    required this.commune,
    required this.profil,
    required this.sousZones,
    required this.svgMobile,
    required this.svgDashboard,
    this.contour = const [],
    this.centre,
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: json['id'] as String,
        nom: json['nom'] as String,
        commune: json['commune'] as String,
        profil: json['profil'] as String,
        sousZones: (json['sousZones'] as List).cast<String>(),
        svgMobile: json['svgMobile'] as String,
        svgDashboard: json['svgDashboard'] as String,
        contour: _contour(json['contour']),
        centre: switch (json['centre']) {
          [final num lon, final num lat] => (lat: lat.toDouble(), lon: lon.toDouble()),
          _ => null,
        },
      );

  /// Anneaux extérieurs d'un contour GeoJSON (Polygon ou MultiPolygon, API).
  static List<List<Geo>> _contour(Object? geojson) {
    if (geojson is! Map<String, dynamic>) return const [];
    final coordonnees = geojson['coordinates'] as List;
    final polygones = geojson['type'] == 'Polygon' ? [coordonnees] : coordonnees;
    return [
      for (final p in polygones)
        [
          for (final c in (p as List).first as List)
            (lat: ((c as List)[1] as num).toDouble(), lon: (c[0] as num).toDouble()),
        ],
    ];
  }

  final String id;
  final String nom;
  final String commune;
  final String profil;
  final List<String> sousZones;

  /// Contour schématique (chemin SVG) pour la carte mobile. Remplacé par un polygone réel en phase 2.
  final String svgMobile;

  /// Contour schématique (chemin SVG) pour la carte du tableau de bord.
  final String svgDashboard;

  /// Contour OpenStreetMap (mode réel) ; vide avec les fixtures.
  final List<List<Geo>> contour;
  final Geo? centre;
}
