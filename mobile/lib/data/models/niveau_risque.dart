/// Niveau de risque d'inondation (diagramme UML : NiveauRisque).
enum NiveauRisque {
  vert,
  jaune,
  orange,
  rouge;

  static NiveauRisque fromJson(String value) => NiveauRisque.values.byName(value);
}

/// Textes associés à un niveau (risk.json > niveaux).
class NiveauInfo {
  const NiveauInfo({required this.label, required this.titre, required this.message});

  factory NiveauInfo.fromJson(Map<String, dynamic> json) => NiveauInfo(
        label: json['label'] as String,
        titre: json['titre'] as String,
        message: json['message'] as String,
      );

  /// Mot court affiché avec la couleur (« Vigilance », « Risque élevé »…).
  final String label;
  final String titre;
  final String message;
}
