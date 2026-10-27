import 'geo.dart';
import 'point_svg.dart';

/// SOS à envoyer (mode réel).
typedef SosEnvoi = ({
  int personnes,
  bool blesses,
  String hauteurEau,
  bool enfantsOuAges,
  Geo? geo,
  double? precisionM,
});

/// Statut d'un SOS (diagramme UML : StatutSOS).
enum StatutSos {
  recu('RECU'),
  enRoute('EN_ROUTE'),
  secouru('SECOURU');

  const StatutSos(this.code);

  final String code;

  static StatutSos fromJson(String code) => StatutSos.values.firstWhere((s) => s.code == code);

  /// Statut suivant (Reçu → En route → Secouru).
  StatutSos get suivant => switch (this) {
        StatutSos.recu => StatutSos.enRoute,
        StatutSos.enRoute => StatutSos.secouru,
        StatutSos.secouru => StatutSos.secouru,
      };
}

/// SOS reçu par les autorités (diagramme UML : SOS ; sos.json > liste).
class Sos {
  const Sos({
    required this.heure,
    required this.lieu,
    required this.nbPersonnes,
    required this.details,
    required this.statut,
    required this.positionDashboard,
  });

  factory Sos.fromJson(Map<String, dynamic> json) => Sos(
        heure: json['heure'] as String,
        lieu: json['lieu'] as String,
        nbPersonnes: json['personnes'] as int,
        details: json['details'] as String,
        statut: StatutSos.fromJson(json['statut'] as String),
        positionDashboard: PointSvg.fromJson(json['svgDashboard'] as Map<String, dynamic>),
      );

  final String heure;
  final String lieu;
  final int nbPersonnes;
  final String details;
  final StatutSos statut;

  /// Position sur la carte schématique du tableau de bord.
  final PointSvg positionDashboard;

  Sos copyWith({StatutSos? statut}) => Sos(
        heure: heure,
        lieu: lieu,
        nbPersonnes: nbPersonnes,
        details: details,
        statut: statut ?? this.statut,
        positionDashboard: positionDashboard,
      );
}

/// Étape du suivi d'un SOS (sos.json > sosCourant.timeline).
class EtapeSos {
  const EtapeSos({required this.etape, required this.detail, required this.fait});

  factory EtapeSos.fromJson(Map<String, dynamic> json) => EtapeSos(
        etape: json['etape'] as String,
        detail: json['detail'] as String,
        fait: json['fait'] as bool,
      );

  final String etape;
  final String detail;
  final bool fait;
}

/// SOS envoyé par l'utilisateur (sos.json > sosCourant).
class SosCourant {
  const SosCourant({
    required this.lieu,
    required this.precisionM,
    required this.nbPersonnes,
    required this.blesses,
    required this.hauteurEau,
    required this.enfantsOuAges,
    required this.timeline,
    this.id,
  });

  factory SosCourant.fromJson(Map<String, dynamic> json) => SosCourant(
        lieu: json['position'] as String,
        precisionM: (json['precisionM'] as num).toDouble(),
        nbPersonnes: json['personnes'] as int,
        blesses: json['blesses'] as bool,
        hauteurEau: json['hauteurEau'] as String,
        enfantsOuAges: json['enfantsOuAges'] as bool,
        timeline: [
          for (final e in json['timeline'] as List) EtapeSos.fromJson(e as Map<String, dynamic>),
        ],
      );

  /// Lieu lisible (« Treichville, avenue 21 »).
  final String lieu;
  final double precisionM;
  final int nbPersonnes;
  final bool blesses;
  final String hauteurEau;
  final bool enfantsOuAges;
  final List<EtapeSos> timeline;

  /// Identifiant du SOS envoyé (mode réel).
  final String? id;
}
