/// Rôle d'un utilisateur (diagramme UML : Role).
enum Role {
  citoyen,
  agent,
  admin;

  static Role fromJson(String value) => Role.values.byName(value.toLowerCase());
}

/// Canal de réception des alertes.
enum Canal { push, email }

/// Utilisateur de l'application ou du tableau de bord (diagramme UML : Utilisateur).
class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.role,
    this.quartierPrincipal,
    this.zonesSuivies = const [],
    this.canauxPreferes = const {},
    this.scoreFiabilite,
    this.service,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    final canaux = (json['canaux'] as Map<String, dynamic>?) ?? const {};
    return Utilisateur(
      id: json['id'] as String,
      // Citoyen : prénom (« Bonjour Awa ») ; agent : nom complet.
      nom: (json['prenom'] ?? json['nom']) as String,
      role: Role.fromJson(json['role'] as String),
      quartierPrincipal: json['quartierPrincipal'] as String?,
      zonesSuivies: ((json['zonesSuivies'] as List?) ?? const []).cast<String>(),
      canauxPreferes: {
        for (final canal in Canal.values)
          if (canaux[canal.name] == true) canal,
      },
      scoreFiabilite: (json['scoreFiabilite'] as num?)?.toDouble(),
      service: json['service'] as String?,
    );
  }

  final String id;
  final String nom;
  final Role role;
  final String? quartierPrincipal;
  final List<String> zonesSuivies;
  final Set<Canal> canauxPreferes;
  final double? scoreFiabilite;
  final String? service;
}
