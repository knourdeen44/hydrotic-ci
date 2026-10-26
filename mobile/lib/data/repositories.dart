import 'models/alerte.dart';
import 'models/niveau_risque.dart';
import 'models/point_svg.dart';
import 'models/risque.dart';
import 'models/signalement.dart';
import 'models/sos.dart';
import 'models/utilisateur.dart';
import 'models/zone.dart';

// Contrats d'accès aux données. Phase 1 : implémentations « mock » (fixtures JSON).
// Phase 2 : implémentations API, branchées dans providers.dart sans toucher aux écrans.

abstract interface class ZoneRepository {
  Future<List<Zone>> zones();
  Future<Zone> zone(String id);
}

abstract interface class RiskRepository {
  Future<Map<NiveauRisque, NiveauInfo>> niveaux();
  Future<RisqueZone> risqueZone(String zoneId);
  Future<List<PluieJour>> pluie();

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
  Future<void> ajouter(Signalement signalement);
}

abstract interface class SosRepository {
  Future<SosCourant> sosCourant();
  Future<List<Sos>> liste();
}

abstract interface class UserRepository {
  Future<Utilisateur> citoyen();
  Future<Utilisateur> agent();
}
