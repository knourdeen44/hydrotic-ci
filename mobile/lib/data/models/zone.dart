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
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: json['id'] as String,
        nom: json['nom'] as String,
        commune: json['commune'] as String,
        profil: json['profil'] as String,
        sousZones: (json['sousZones'] as List).cast<String>(),
        svgMobile: json['svgMobile'] as String,
        svgDashboard: json['svgDashboard'] as String,
      );

  final String id;
  final String nom;
  final String commune;
  final String profil;
  final List<String> sousZones;

  /// Contour schématique (chemin SVG) pour la carte mobile. Remplacé par un polygone réel en phase 2.
  final String svgMobile;

  /// Contour schématique (chemin SVG) pour la carte du tableau de bord.
  final String svgDashboard;
}
