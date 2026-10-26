import 'niveau_risque.dart';

/// Statut d'une alerte (diagramme UML : StatutAlerte).
enum StatutAlerte {
  envoyee('ENVOYEE'),
  enAttente('EN_ATTENTE');

  const StatutAlerte(this.code);

  final String code;

  static StatutAlerte fromJson(String code) =>
      StatutAlerte.values.firstWhere((s) => s.code == code);
}

/// Alerte d'une zone (diagramme UML : Alerte).
class Alerte {
  const Alerte({
    required this.id,
    required this.zoneId,
    required this.niveau,
    required this.titre,
    required this.corps,
    required this.statut,
    required this.date,
    required this.source,
    this.probabilite,
    this.signalementsConfirmes,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) => Alerte(
        id: json['id'] as String,
        zoneId: json['zone'] as String,
        niveau: NiveauRisque.fromJson(json['niveau'] as String),
        titre: json['titre'] as String,
        corps: json['corps'] as String,
        statut: StatutAlerte.fromJson(json['statut'] as String),
        date: json['date'] as String,
        source: json['source'] as String,
        probabilite: (json['probabilite'] as num?)?.toDouble(),
        signalementsConfirmes: json['signalementsConfirmes'] as int?,
      );

  final String id;
  final String zoneId;
  final NiveauRisque niveau;
  final String titre;
  final String corps;
  final StatutAlerte statut;

  /// Date déjà formatée pour l'affichage (« Mercredi 17 juin · 18:42 »).
  final String date;
  final String source;
  final double? probabilite;
  final int? signalementsConfirmes;

  Alerte copyWith({StatutAlerte? statut}) => Alerte(
        id: id,
        zoneId: zoneId,
        niveau: niveau,
        titre: titre,
        corps: corps,
        statut: statut ?? this.statut,
        date: date,
        source: source,
        probabilite: probabilite,
        signalementsConfirmes: signalementsConfirmes,
      );
}
