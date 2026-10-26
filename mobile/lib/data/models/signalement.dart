import 'point_svg.dart';

/// Statut d'un signalement.
enum StatutSignalement {
  aConfirmer('A_CONFIRMER'),
  confirme('CONFIRME');

  const StatutSignalement(this.code);

  final String code;

  static StatutSignalement fromJson(String code) =>
      StatutSignalement.values.firstWhere((s) => s.code == code);
}

/// Votes d'un signalement après une réponse « oui » (reports.json > apresOui).
typedef VotesApresOui = ({StatutSignalement statut, int oui, int non});

/// Inondation signalée par un habitant (diagramme UML : Signalement).
class Signalement {
  const Signalement({
    required this.id,
    required this.zoneId,
    required this.rue,
    required this.statut,
    required this.oui,
    required this.non,
    required this.il,
    required this.position,
    this.distanceUtilisateur,
    this.hauteurEau,
    this.apresOui,
  });

  factory Signalement.fromJson(Map<String, dynamic> json) {
    final apresOui = json['apresOui'] as Map<String, dynamic>?;
    return Signalement(
      id: json['id'] as String,
      zoneId: json['zone'] as String,
      rue: json['rue'] as String,
      statut: StatutSignalement.fromJson(json['statut'] as String),
      oui: json['oui'] as int,
      non: json['non'] as int,
      il: json['il'] as String,
      position: PointSvg.fromJson(json['svg'] as Map<String, dynamic>),
      distanceUtilisateur: json['distanceUtilisateur'] as String?,
      hauteurEau: json['hauteurEau'] as String?,
      apresOui: apresOui == null
          ? null
          : (
              statut: StatutSignalement.fromJson(apresOui['statut'] as String),
              oui: apresOui['oui'] as int,
              non: apresOui['non'] as int,
            ),
    );
  }

  final String id;
  final String zoneId;
  final String rue;
  final StatutSignalement statut;
  final int oui;
  final int non;

  /// Ancienneté déjà formatée (« 38 min »).
  final String il;

  /// Position sur la carte schématique mobile.
  final PointSvg position;
  final String? distanceUtilisateur;
  final String? hauteurEau;
  final VotesApresOui? apresOui;

  Signalement copyWith({StatutSignalement? statut, int? oui, int? non}) => Signalement(
        id: id,
        zoneId: zoneId,
        rue: rue,
        statut: statut ?? this.statut,
        oui: oui ?? this.oui,
        non: non ?? this.non,
        il: il,
        position: position,
        distanceUtilisateur: distanceUtilisateur,
        hauteurEau: hauteurEau,
        apresOui: apresOui,
      );
}
