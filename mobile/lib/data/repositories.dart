import 'models/alerte.dart';
import 'models/confirmation.dart';
import 'models/niveau_risque.dart';
import 'models/point_svg.dart';
import 'models/risque.dart';
import 'models/signalement.dart';
import 'models/sos.dart';
import 'models/utilisateur.dart';
import 'models/zone.dart';

// Contrats d'accès aux données : implémentations « mock » (fixtures JSON, mode démo)
// et API (mode réel), branchées dans providers.dart.

abstract interface class ZoneRepository {
  Future<List<Zone>> zones();
  Future<Zone> zone(String id);
}

abstract interface class RiskRepository {
  Future<Map<NiveauRisque, NiveauInfo>> niveaux();
  Future<RisqueZone> risqueZone(String zoneId);
  Future<List<PluieJour>> pluie([String? zoneId]);

  /// Consignes à suivre pour un niveau (liste vide si aucune).
  Future<List<String>> consignes(NiveauRisque niveau);
}

abstract interface class AlertRepository {
  Future<List<Alerte>> alertes();
  Future<Alerte> alerte(String id);

  /// Modèles de messages (clé : orange, rouge, confirmation, sosRecu, finAlerte).
  Future<Map<String, String>> modeles();
}

abstract interface class ReportRepository {
  Future<List<Signalement>> signalements();
  Future<PointSvg> positionUtilisateur();
  Future<void> ajouter(Signalement signalement, {String? commentaire});

  /// Réponse de l'habitant à une demande de confirmation.
  Future<void> confirmer(String signalementId, OuiNonInconnu reponse);
}

abstract interface class SosRepository {
  Future<SosCourant> sosCourant();
  Future<List<Sos>> liste();

  /// Envoie un SOS et renvoie son suivi.
  Future<SosCourant> envoyer(SosEnvoi envoi);

  Future<SosCourant> suivre(String id);
}

abstract interface class UserRepository {
  Future<Utilisateur> citoyen();
  Future<Utilisateur> agent();

  /// Enregistre les préférences de l'habitant (quartiers suivis, canaux d'alerte).
  Future<void> enregistrer({List<String>? zonesSuivies, Set<Canal>? canaux});
}
