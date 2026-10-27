import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/niveau_risque.dart';
import '../../data/models/risque.dart';
import '../../data/models/utilisateur.dart';
import '../../data/models/zone.dart';
import '../../data/providers.dart';
import '../../state/app_state.dart';

/// Données de l'accueil (M1) pour la zone active.
/// `quartier` : ligne sous la salutation (« Treichville · Avenue 21 »).
typedef AccueilDonnees = ({
  Utilisateur citoyen,
  List<String> zonesSuivies,
  Zone zone,
  String quartier,
  Map<NiveauRisque, NiveauInfo> niveaux,
  RisqueZone risque,
  List<PluieJour> pluie,
});

final accueilProvider = FutureProvider<AccueilDonnees>((ref) async {
  // Dépendances lues avant tout await.
  final zoneActive = ref.watch(zoneActiveProvider);
  final citoyenF = ref.watch(citoyenProvider.future);
  final suiviesF = ref.watch(zonesSuiviesProvider.future);
  final zonesF = ref.watch(zonesProvider.future);
  final niveauxF = ref.watch(niveauxProvider.future);
  final risk = ref.watch(riskRepositoryProvider);

  final citoyen = await citoyenF;
  final suivies = await suiviesF;
  final zoneId = zoneActive != null && suivies.contains(zoneActive) ? zoneActive : suivies.first;
  final zone = (await zonesF).firstWhere((z) => z.id == zoneId);
  final principale = zoneId == citoyen.zonesSuivies.first;
  return (
    citoyen: citoyen,
    zonesSuivies: suivies,
    zone: zone,
    quartier: principale && citoyen.quartierPrincipal != null
        ? citoyen.quartierPrincipal!
        : '${zone.nom} · ${zone.commune}',
    niveaux: await niveauxF,
    risque: await risk.risqueZone(zoneId),
    pluie: await risk.pluie(zoneId),
  );
});
