import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/alerte.dart';
import '../../data/models/niveau_risque.dart';
import '../../data/models/point_svg.dart';
import '../../data/models/risque.dart';
import '../../data/models/signalement.dart';
import '../../data/models/sos.dart';
import '../../data/models/utilisateur.dart';
import '../../data/models/zone.dart';
import '../../data/providers.dart';

/// Données fictives affichées par le catalogue de composants (développement).
typedef CatalogueDonnees = ({
  Utilisateur citoyen,
  Alerte alerte,
  List<Zone> zones,
  Map<NiveauRisque, NiveauInfo> niveaux,
  RisqueZone risque,
  List<PluieJour> pluie,
  Map<NiveauRisque, List<String>> consignes,
  List<Signalement> signalements,
  PointSvg positionVous,
  SosCourant sosCourant,
  List<Sos> sos,
});

final catalogueProvider = FutureProvider<CatalogueDonnees>((ref) async {
  // Dépôts lus avant tout await (dépendances Riverpod synchrones).
  final users = ref.watch(userRepositoryProvider);
  final alerts = ref.watch(alertRepositoryProvider);
  final zones = ref.watch(zoneRepositoryProvider);
  final risk = ref.watch(riskRepositoryProvider);
  final reports = ref.watch(reportRepositoryProvider);
  final sos = ref.watch(sosRepositoryProvider);
  final citoyen = await users.citoyen();
  return (
    citoyen: citoyen,
    alerte: await alerts.alerte('al-1'),
    zones: await zones.zones(),
    niveaux: await risk.niveaux(),
    risque: await risk.risqueZone(citoyen.zonesSuivies.first),
    pluie: await risk.pluie(),
    consignes: {for (final n in NiveauRisque.values) n: await risk.consignes(n)},
    signalements: await reports.signalements(),
    positionVous: await reports.positionUtilisateur(),
    sosCourant: await sos.sosCourant(),
    sos: await sos.liste(),
  );
});
