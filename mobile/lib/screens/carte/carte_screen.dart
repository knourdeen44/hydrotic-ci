import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/confirmation.dart';
import '../../data/models/niveau_risque.dart';
import '../../data/models/signalement.dart';
import '../../data/mode.dart';
import '../../data/providers.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/carte_osm.dart';
import '../../widgets/confirm_question_sheet.dart';
import '../../widgets/schematic_map.dart';
import '../../widgets/toast.dart';
import '../shell/citizen_scaffold.dart';
import 'carte_data.dart';

/// M3 — Carte schématique et confirmation communautaire.
/// Avec [scenario], rejoue la vidéo v2_confirmation (apparition, question, « Oui »).
class CarteScreen extends ConsumerStatefulWidget {
  const CarteScreen({super.key, this.scenario = false});

  final bool scenario;

  @override
  ConsumerState<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends ConsumerState<CarteScreen> {
  // Délais du prototype s2_confirmation.
  static const _popSignalement = Duration(milliseconds: 1000);
  static const _ouvertureFeuille = Duration(milliseconds: 2000);
  static const _reponseSimulee = Duration(milliseconds: 4550);
  static const _delaiMerci = Duration(milliseconds: 450);
  static const _delaiCarte = Duration(milliseconds: 1050);
  // Niveaux visibles dans la vidéo (jour de l'alerte).
  static const _niveauxScenario = {'treichville': NiveauRisque.orange};

  final _timers = <Timer>[];
  bool? _feuilleOuverte;
  bool _actifVisible = true;
  OuiNonInconnu? _reponse;
  Signalement? _avantReponse;
  bool _merciVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.scenario) {
      _actifVisible = false;
      _feuilleOuverte = false;
      _plusTard(_popSignalement, () => setState(() => _actifVisible = true));
      _plusTard(_ouvertureFeuille, () => setState(() => _feuilleOuverte = true));
      _plusTard(_reponseSimulee, () {
        final actif = _actif(ref.read(carteProvider).valueOrNull?.signalements);
        if (actif != null) _repondre(actif, OuiNonInconnu.oui);
      });
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _plusTard(Duration delai, VoidCallback action) => _timers.add(Timer(delai, () {
        if (mounted) action();
      }));

  /// Signalement à confirmer près de l'habitant (celui qui a une distance).
  static Signalement? _actif(List<Signalement>? signalements) =>
      signalements?.where((s) => s.distanceUtilisateur != null).firstOrNull;

  void _repondre(Signalement actif, OuiNonInconnu reponse) {
    if (_reponse != null) return;
    setState(() {
      _reponse = reponse;
      _avantReponse = actif;
      // La feuille reste ouverte (état « Merci ») après l'enregistrement de la réponse.
      _feuilleOuverte = true;
    });
    _plusTard(_delaiMerci, () => setState(() => _merciVisible = true));
    if (modeApi) {
      ref.read(reportRepositoryProvider).confirmer(actif.id, reponse).then(
        (_) => _plusTard(_delaiCarte, () => ref.invalidate(signalementsProvider)),
        onError: (Object e) {
          if (mounted) showToast(context, '$e');
        },
      );
    }
    _plusTard(_delaiCarte, () {
      ref.read(confirmationsProvider.notifier).update((m) => {...m, actif.id: reponse});
    });
  }

  void _fermerFeuille() => setState(() => _feuilleOuverte = false);

  @override
  Widget build(BuildContext context) {
    final etat = ref.watch(carteProvider);
    final d = etat.valueOrNull;
    final confirmations = ref.watch(confirmationsProvider);
    final actif = _actif(d?.signalements);
    final ouverte = _feuilleOuverte ?? (actif != null && confirmations[actif.id] == null);
    return CitizenScaffold(
      tab: HydroticTab.carte,
      showSosFab: !ouverte,
      body: d == null
          ? (etat.hasError
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(Fr.erreurChargement, textAlign: TextAlign.center, style: HydroticText.body),
                  ),
                )
              : const SizedBox.shrink())
          : Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: ouverte ? _fermerFeuille : null,
                  child: modeApi
                      ? CarteOsm(
                          zones: [
                            for (final z in d.zones) (zone: z, niveau: _niveauZone(z.id, d, confirmations)),
                          ],
                          signalements: d.signalements,
                          vous: ref.watch(positionGpsProvider).valueOrNull?.geo,
                          signalementActifId: actif?.id,
                        )
                      : SchematicMap(
                    zones: [
                      for (final z in d.zones)
                        (zone: z, niveau: _niveauZone(z.id, d, confirmations)),
                    ],
                    signalements: [
                      for (final s in d.signalements)
                        if (s.id != actif?.id || _actifVisible) s,
                    ],
                    positionVous: d.positionVous,
                    signalementActifId: _actifVisible ? actif?.id : null,
                    tronconsConfirmes: {
                      for (final s in d.signalements)
                        if (s.statut == StatutSignalement.confirme && s.svgTroncon != null) s.id,
                    },
                  ),
                ),
                if (ouverte && actif != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onVerticalDragEnd: (e) {
                        if ((e.primaryVelocity ?? 0) > 200) _fermerFeuille();
                      },
                      child: _feuille(actif, d.citoyen.scoreFiabilite ?? 0),
                    ),
                  ),
              ],
            ),
    );
  }

  NiveauRisque _niveauZone(String zoneId, CarteDonnees d, Map<String, OuiNonInconnu> confirmations) {
    // Inondation confirmée par l'habitant dans la zone : la zone passe en rouge.
    final confirmee = d.signalements
        .any((s) => s.zoneId == zoneId && confirmations[s.id] == OuiNonInconnu.oui);
    if (confirmee) return NiveauRisque.rouge;
    return (widget.scenario ? _niveauxScenario[zoneId] : null) ?? d.niveauxAujourdhui[zoneId]!;
  }

  Widget _feuille(Signalement actif, double fiabilite) {
    final avant = _avantReponse ?? actif;
    final reponse = _reponse;
    MerciContenu? merci;
    if (_merciVisible && reponse != null) {
      final apres = appliquerReponse(avant, reponse);
      merci = MerciContenu(
        message: reponse == OuiNonInconnu.oui
            ? TextSpan(children: [
                TextSpan(text: Fr.rueDeuxPoints(avant.rue)),
                const TextSpan(
                  text: Fr.inondationConfirmee,
                  style: TextStyle(color: HydroticColors.riskRouge, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: Fr.parHabitants(apres.oui)),
              ])
            : null,
        metaGauche: Fr.votreFiabilite(fiabilite),
        metaDroite: Fr.votes(apres.oui, apres.non),
      );
    }
    return ConfirmQuestionSheet(
      question: Fr.questionRue(avant.rue),
      sousTitre: Fr.vousEtesA(avant.distanceUtilisateur ?? ''),
      metaGauche: Fr.signaleIlYA(avant.il),
      metaDroite: Fr.votes(avant.oui, avant.non),
      onReponse: (r) => _repondre(actif, r),
      merci: merci,
    );
  }
}
