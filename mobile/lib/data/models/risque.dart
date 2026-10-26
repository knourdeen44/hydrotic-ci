import 'niveau_risque.dart';

/// Prévision de risque d'une zone (risk.json > parZone ; diagramme UML : Prediction).
class RisqueZone {
  const RisqueZone({
    required this.zoneId,
    required this.aujourdhui,
    required this.demain,
    required this.signalementsConfirmes,
    required this.majIl,
  });

  factory RisqueZone.fromJson(String zoneId, Map<String, dynamic> json) => RisqueZone(
        zoneId: zoneId,
        aujourdhui: NiveauRisque.fromJson(json['aujourdhui'] as String),
        demain: NiveauRisque.fromJson(json['demain'] as String),
        signalementsConfirmes: json['signalementsConfirmes'] as int,
        majIl: json['majIl'] as String,
      );

  final String zoneId;
  final NiveauRisque aujourdhui;
  final NiveauRisque demain;
  final int signalementsConfirmes;

  /// Ancienneté de la mise à jour, déjà formatée (« 2 min »).
  final String majIl;
}

/// Pluie d'un jour (risk.json > pluie ; diagramme UML : Observation).
class PluieJour {
  const PluieJour({required this.label, required this.mm, required this.prevision});

  final String label;
  final double mm;

  /// Vrai pour les jours prévus (barres hachurées).
  final bool prevision;
}
