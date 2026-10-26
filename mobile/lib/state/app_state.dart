import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/alerte.dart';
import '../data/models/confirmation.dart';
import '../data/models/niveau_risque.dart';
import '../data/models/point_svg.dart';
import '../data/models/risque.dart';
import '../data/models/signalement.dart';
import '../data/models/sos.dart';
import '../data/models/utilisateur.dart';
import '../data/models/zone.dart';
import '../data/providers.dart';

// État partagé des écrans. Les dépôts sont lus avant tout `await` (dépendances synchrones).

final citoyenProvider = FutureProvider<Utilisateur>((ref) => ref.watch(userRepositoryProvider).citoyen());

final zonesProvider = FutureProvider<List<Zone>>((ref) => ref.watch(zoneRepositoryProvider).zones());

final niveauxProvider =
    FutureProvider<Map<NiveauRisque, NiveauInfo>>((ref) => ref.watch(riskRepositoryProvider).niveaux());

final pluieProvider = FutureProvider<List<PluieJour>>((ref) => ref.watch(riskRepositoryProvider).pluie());

final risqueZoneProvider = FutureProvider.family<RisqueZone, String>(
  (ref, zoneId) => ref.watch(riskRepositoryProvider).risqueZone(zoneId),
);

final consignesProvider = FutureProvider.family<List<String>, NiveauRisque>(
  (ref, niveau) => ref.watch(riskRepositoryProvider).consignes(niveau),
);

final alerteProvider = FutureProvider.family<Alerte, String>(
  (ref, id) => ref.watch(alertRepositoryProvider).alerte(id),
);

final positionVousProvider =
    FutureProvider<PointSvg>((ref) => ref.watch(reportRepositoryProvider).positionUtilisateur());

final sosCourantProvider = FutureProvider<SosCourant>((ref) => ref.watch(sosRepositoryProvider).sosCourant());

/// Zone affichée sur l'accueil (puce « 2 zones »). Nul : zone principale du citoyen.
final zoneActiveProvider = StateProvider<String?>((ref) => null);

/// Réponses locales aux demandes de confirmation (identifiant du signalement → réponse).
final confirmationsProvider = StateProvider<Map<String, OuiNonInconnu>>((ref) => const {});

/// Signalements avec les réponses locales appliquées.
final signalementsProvider = FutureProvider<List<Signalement>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  final confirmations = ref.watch(confirmationsProvider);
  final signalements = await repo.signalements();
  return [for (final s in signalements) appliquerReponse(s, confirmations[s.id])];
});

/// Votes d'un signalement après la réponse de l'habitant.
Signalement appliquerReponse(Signalement s, OuiNonInconnu? reponse) {
  final apres = s.apresOui;
  return switch (reponse) {
    OuiNonInconnu.oui when apres != null => s.copyWith(statut: apres.statut, oui: apres.oui, non: apres.non),
    OuiNonInconnu.oui => s.copyWith(oui: s.oui + 1),
    OuiNonInconnu.non => s.copyWith(non: s.non + 1),
    OuiNonInconnu.inconnu || null => s,
  };
}
