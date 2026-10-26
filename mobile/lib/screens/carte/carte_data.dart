import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/niveau_risque.dart';
import '../../data/models/point_svg.dart';
import '../../data/models/signalement.dart';
import '../../data/models/utilisateur.dart';
import '../../data/models/zone.dart';
import '../../data/providers.dart';
import '../../state/app_state.dart';

/// Données de la carte (M3) : niveau du jour par zone, signalements (réponses locales appliquées).
typedef CarteDonnees = ({
  Utilisateur citoyen,
  List<Zone> zones,
  Map<String, NiveauRisque> niveauxAujourdhui,
  List<Signalement> signalements,
  PointSvg positionVous,
});

final carteProvider = FutureProvider<CarteDonnees>((ref) async {
  // Dépendances lues avant tout await.
  final citoyenF = ref.watch(citoyenProvider.future);
  final zonesF = ref.watch(zonesProvider.future);
  final signalementsF = ref.watch(signalementsProvider.future);
  final positionF = ref.watch(positionVousProvider.future);
  final risk = ref.watch(riskRepositoryProvider);

  final zones = await zonesF;
  return (
    citoyen: await citoyenF,
    zones: zones,
    niveauxAujourdhui: {for (final z in zones) z.id: (await risk.risqueZone(z.id)).aujourdhui},
    signalements: await signalementsF,
    positionVous: await positionF,
  );
});
