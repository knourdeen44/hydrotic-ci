import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/alerte.dart';
import '../../data/models/niveau_risque.dart';
import '../../data/models/zone.dart';
import '../../data/providers.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../theme/risk_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/hydrotic_button.dart';
import '../../widgets/risk_card.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/section_title.dart';
import '../shell/citizen_scaffold.dart';
import '../shell/consignes_overlay.dart';

/// Alertes reçues par le citoyen : seules les alertes envoyées (les alertes en attente de
/// validation par les autorités ne sont pas diffusées), les plus récentes d'abord.
final alertesRecuesProvider = FutureProvider<({List<Alerte> alertes, List<Zone> zones, Map<NiveauRisque, NiveauInfo> niveaux})>(
  (ref) async {
    final alertesF = ref.watch(alertRepositoryProvider).alertes();
    final zonesF = ref.watch(zonesProvider.future);
    final niveauxF = ref.watch(niveauxProvider.future);
    final alertes = await alertesF;
    return (
      alertes: alertes.where((a) => a.statut == StatutAlerte.envoyee).toList(),
      zones: await zonesF,
      niveaux: await niveauxF,
    );
  },
);

/// M5 — Alertes : alerte en cours, historique, bulletins officiels.
class AlertesScreen extends ConsumerStatefulWidget {
  const AlertesScreen({super.key});

  @override
  ConsumerState<AlertesScreen> createState() => _AlertesScreenState();
}

class _AlertesScreenState extends ConsumerState<AlertesScreen> {
  bool _consignes = false;

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(alertesRecuesProvider).valueOrNull;
    final enCours = d?.alertes.firstOrNull;
    String nomZone(String id) => d?.zones.firstWhere((z) => z.id == id).nom ?? '';
    return CitizenScaffold(
      tab: HydroticTab.alertes,
      body: Column(
        children: [
          const ScreenHeader(titre: Fr.navAlertes),
          Expanded(
            child: d == null
                ? const SizedBox.shrink()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      HydroticSpacing.screenPadding,
                      0,
                      HydroticSpacing.screenPadding,
                      HydroticSpacing.screenPadding + HydroticSizes.sosFab,
                    ),
                    children: [
                      if (enCours != null) ...[
                        RiskCard.compact(
                          niveau: enCours.niveau,
                          surTitre: '${nomZone(enCours.zoneId)} · ${enCours.date}',
                          titre: d.niveaux[enCours.niveau]?.titre ?? enCours.titre,
                        ),
                        const SizedBox(height: HydroticSpacing.gapM),
                        HydroticButton(
                          label: Fr.voirConsignes,
                          secondary: true,
                          onPressed: () => setState(() => _consignes = true),
                        ),
                      ],
                      const SectionTitle(Fr.historique),
                      for (final alerte in d.alertes) _LigneAlerte(alerte: alerte, niveaux: d.niveaux),
                      const SectionTitle(Fr.bulletinsOfficiels),
                      Container(
                        padding: const EdgeInsets.all(HydroticSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: HydroticColors.slateXLight,
                          borderRadius: BorderRadius.circular(HydroticRadius.card),
                        ),
                        child: Text(
                          Fr.bulletinsVide,
                          style: HydroticText.body.copyWith(color: HydroticColors.grayLight),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      overlays: [
        if (_consignes && enCours != null)
          ...consignesOverlay(
            niveau: enCours.niveau,
            zone: nomZone(enCours.zoneId),
            onClose: () => setState(() => _consignes = false),
          ),
      ],
    );
  }
}

/// Ligne d'historique : pastille et mot du niveau, titre, date, source.
class _LigneAlerte extends StatelessWidget {
  const _LigneAlerte({required this.alerte, required this.niveaux});

  final Alerte alerte;
  final Map<NiveauRisque, NiveauInfo> niveaux;

  @override
  Widget build(BuildContext context) {
    final petit = HydroticText.small.copyWith(color: HydroticColors.grayLight);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: HydroticSpacing.gapM),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HydroticColors.slateXLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: alerte.niveau.couleur, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: HydroticSpacing.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alerte.titre, style: HydroticText.sectionTitle.copyWith(color: HydroticColors.gray)),
                const SizedBox(height: 2),
                Text(alerte.date, style: HydroticText.caption.copyWith(color: HydroticColors.gray)),
                const SizedBox(height: 2),
                Text('${niveaux[alerte.niveau]?.label ?? ''} · ${alerte.source}', style: petit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
