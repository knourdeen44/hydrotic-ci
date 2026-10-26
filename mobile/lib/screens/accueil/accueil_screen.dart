import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/alerte.dart';
import '../../data/models/niveau_risque.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/risk_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/hydrotic_header.dart';
import '../../widgets/mini_stat.dart';
import '../../widgets/notification_banner.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/rain_bars.dart';
import '../../widgets/risk_card.dart';
import '../../widgets/section_title.dart';
import '../shell/citizen_scaffold.dart';
import '../shell/consignes_overlay.dart';
import 'accueil_data.dart';

/// M1 — Accueil. Avec [scenarioAlerte], rejoue M2 (réception d'une alerte, vidéo v1_alerte).
class AccueilScreen extends ConsumerStatefulWidget {
  const AccueilScreen({super.key, this.scenarioAlerte = false});

  final bool scenarioAlerte;

  @override
  ConsumerState<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends ConsumerState<AccueilScreen> {
  // Scénario M2 : délais du prototype s1_alerte.
  static const _alerteId = 'al-1';
  static const _debutBanniere = Duration(milliseconds: 1400);
  // Appui simulé sur la bannière à 3,6 s (entrée terminée à 1,976 s).
  static const _dureeBanniereScenario = Duration(milliseconds: 1624);
  static const _delaiFondu = Duration(milliseconds: 700);
  static const _delaiConsignes = Duration(milliseconds: 1200);

  final _timers = <Timer>[];

  /// Niveau de demain imposé par le scénario (jaune au départ, puis celui de l'alerte).
  NiveauRisque? _niveauDemainForce;
  Alerte? _banniere;

  /// Niveau des consignes affichées ; nul si la feuille est fermée.
  NiveauRisque? _consignes;

  @override
  void initState() {
    super.initState();
    if (widget.scenarioAlerte) {
      _niveauDemainForce = NiveauRisque.jaune;
      _plusTard(_debutBanniere, _afficherAlerte);
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

  Future<void> _afficherAlerte() async {
    final alerte = await ref.read(alerteProvider(_alerteId).future);
    if (mounted) setState(() => _banniere = alerte);
  }

  void _banniereSortie() {
    final alerte = _banniere;
    setState(() => _banniere = null);
    if (alerte == null) return;
    _plusTard(_delaiFondu, () => setState(() => _niveauDemainForce = alerte.niveau));
    _plusTard(_delaiFondu + _delaiConsignes, () => setState(() => _consignes = alerte.niveau));
  }

  void _zoneSuivante(AccueilDonnees d) {
    final suivies = d.zonesSuivies;
    final suivante = suivies[(suivies.indexOf(d.zone.id) + 1) % suivies.length];
    ref.read(zoneActiveProvider.notifier).state = suivante;
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(accueilProvider).valueOrNull;
    final banniere = _banniere;
    final consignes = _consignes;
    return CitizenScaffold(
      tab: HydroticTab.accueil,
      body: d == null ? const SizedBox.shrink() : _contenu(d),
      overlays: [
        if (consignes != null && d != null)
          ...consignesOverlay(
            niveau: consignes,
            zone: d.zone.nom,
            onClose: () => setState(() => _consignes = null),
          ),
        if (banniere != null)
          Positioned(
            left: 10,
            right: 10,
            top: 8,
            child: NotificationBanner(
              key: ValueKey(banniere.id),
              titre: banniere.titre,
              titreColor: banniere.niveau.couleur,
              corps: banniere.corps,
              displayDuration:
                  widget.scenarioAlerte ? _dureeBanniereScenario : const Duration(milliseconds: 2500),
              onDismissed: _banniereSortie,
            ),
          ),
      ],
    );
  }

  Widget _contenu(AccueilDonnees d) {
    final demain = _niveauDemainForce ?? d.risque.demain;
    final info = d.niveaux[demain]!;
    final aujourdhui = d.risque.aujourdhui;
    return Column(
      children: [
        HydroticHeader(
          prenom: d.citoyen.nom,
          quartier: d.quartier,
          nbZones: d.zonesSuivies.length,
          onZonesTap: () => _zoneSuivante(d),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              HydroticSpacing.screenPadding,
              0,
              HydroticSpacing.screenPadding,
              HydroticSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RiskCard(
                  niveau: demain,
                  surTitre: Fr.demainNiveau(demain.name),
                  titre: info.titre,
                  message: info.message,
                ),
                const SizedBox(height: HydroticSpacing.gapL),
                Row(
                  children: [
                    Expanded(
                      child: MiniStat(
                        label: Fr.aujourdhui,
                        value: d.niveaux[aujourdhui]!.label,
                        dotColor: aujourdhui.couleur,
                      ),
                    ),
                    const SizedBox(width: HydroticSpacing.gapM),
                    Expanded(
                      child: MiniStat(
                        label: Fr.signalements,
                        value: Fr.confirmes(d.risque.signalementsConfirmes),
                      ),
                    ),
                  ],
                ),
                const SectionTitle(Fr.pluieTitre),
                RainBars(jours: d.pluie),
                const SectionTitle(Fr.accesRapide),
                QuickActions(
                  onCarte: () => context.go('/carte'),
                  onSignaler: () => context.push('/signaler'),
                  onConsignes: () => setState(() => _consignes = demain),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
