import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/confirmation.dart';
import '../../data/models/niveau_risque.dart';
import '../../data/models/sos.dart';
import '../../l10n/fr.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../theme/risk_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/confirm_question_sheet.dart';
import '../../widgets/consignes_sheet.dart';
import '../../widgets/hydrotic_header.dart';
import '../../widgets/mini_stat.dart';
import '../../widgets/notification_banner.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/rain_bars.dart';
import '../../widgets/risk_card.dart';
import '../../widgets/schematic_map.dart';
import '../../widgets/sos_fab.dart';
import '../../widgets/sos_hold_button.dart';
import '../../widgets/sos_status_timeline.dart';
import '../../widgets/status_chip.dart';
import 'catalog_data.dart';

// Catalogue de développement (étape 4) : tous les composants avec les données fictives.
// Les libellés de section sont des noms de composants (page non destinée aux habitants).
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  var _niveau = NiveauRisque.jaune;
  var _tab = HydroticTab.accueil;
  var _banniere = 0;
  var _banniereVisible = true;
  OuiNonInconnu? _reponse;
  var _sosEnvoye = false;
  var _statut = StatutSos.recu;

  void _toast(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final donnees = ref.watch(catalogueProvider);
    return Scaffold(
      body: SafeArea(
        child: donnees.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: _catalogue,
        ),
      ),
    );
  }

  Widget _catalogue(CatalogueDonnees d) {
    final zone = d.zones.firstWhere((z) => z.id == d.risque.zoneId);
    final info = d.niveaux[_niveau]!;
    final sg1 = d.signalements.first;
    final apres = sg1.apresOui;
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _Section('HydroticHeader', padded: false, actions: [
          TextButton(onPressed: () => context.push('/theme'), child: const Text('Thème')),
        ]),
        HydroticHeader(
          prenom: d.citoyen.nom,
          quartier: d.citoyen.quartierPrincipal ?? '',
          nbZones: d.citoyen.zonesSuivies.length,
          onZonesTap: () => _toast(Fr.bientot),
        ),
        _Section('RiskCard — appuyer pour changer de niveau', actions: [
          TextButton(
            onPressed: () => setState(
              () => _niveau = NiveauRisque.values[(_niveau.index + 1) % NiveauRisque.values.length],
            ),
            child: const Text('Niveau suivant'),
          ),
        ]),
        _pad(RiskCard(
          niveau: _niveau,
          surTitre: Fr.demainNiveau(_niveau.name),
          titre: info.titre,
          message: info.message,
        )),
        const _Section('MiniStat'),
        _pad(Row(children: [
          Expanded(
            child: MiniStat(
              label: Fr.aujourdhui,
              value: d.niveaux[d.risque.aujourdhui]!.label,
              dotColor: d.risque.aujourdhui.couleur,
            ),
          ),
          const SizedBox(width: HydroticSpacing.gapM),
          Expanded(
            child: MiniStat(label: Fr.signalements, value: Fr.confirmes(d.risque.signalementsConfirmes)),
          ),
        ])),
        const _Section('RainBars'),
        _pad(RainBars(jours: d.pluie)),
        const _Section('QuickActions'),
        _pad(QuickActions(onCarte: () => _toast(Fr.actionCarte), onSignaler: () => _toast(Fr.actionSignaler))),
        const _Section('SosFab'),
        _pad(Align(alignment: Alignment.centerRight, child: SosFab(onPressed: () => _toast(Fr.sos)))),
        const _Section('BottomNav'),
        BottomNav(current: _tab, onTap: (t) => setState(() => _tab = t)),
        _Section('NotificationBanner', actions: [
          TextButton(
            onPressed: () => setState(() {
              _banniere++;
              _banniereVisible = true;
            }),
            child: const Text('Rejouer'),
          ),
        ]),
        SizedBox(
          height: 120,
          child: ClipRect(
            child: _banniereVisible
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                    child: NotificationBanner(
                      key: ValueKey(_banniere),
                      titre: d.alerte.titre,
                      titreColor: d.alerte.niveau.couleur,
                      corps: d.alerte.corps,
                      onDismissed: () => setState(() => _banniereVisible = false),
                    ),
                  )
                : null,
          ),
        ),
        const _Section('ConsignesSheet'),
        ConsignesSheet(
          animate: false,
          titre: Fr.queFaireAvantDemain,
          sousTitre: Fr.consignesPour(NiveauRisque.orange.name, zone.nom),
          consignes: d.consignes[NiveauRisque.orange]!,
          niveau: NiveauRisque.orange,
        ),
        _Section('ConfirmQuestionSheet', actions: [
          TextButton(onPressed: () => setState(() => _reponse = null), child: const Text('Réinitialiser')),
        ]),
        ConfirmQuestionSheet(
          animate: false,
          question: Fr.questionRue(sg1.rue),
          sousTitre: Fr.vousEtesA(sg1.distanceUtilisateur ?? ''),
          metaGauche: Fr.signaleIlYA(sg1.il),
          metaDroite: Fr.votes(sg1.oui, sg1.non),
          onReponse: (r) => setState(() => _reponse = r),
          merci: _reponse == null || apres == null
              ? null
              : MerciContenu(
                  message: TextSpan(children: [
                    TextSpan(text: Fr.rueDeuxPoints(sg1.rue)),
                    TextSpan(
                      text: Fr.inondationConfirmee,
                      style: const TextStyle(color: HydroticColors.riskRouge, fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: Fr.parHabitants(apres.oui)),
                  ]),
                  metaGauche: Fr.votreFiabilite(d.citoyen.scoreFiabilite ?? 0),
                  metaDroite: Fr.votes(apres.oui, apres.non),
                ),
        ),
        const _Section('SchematicMap'),
        SizedBox(
          height: 420,
          child: SchematicMap(
            zones: [
              for (final z in d.zones)
                (zone: z, niveau: _reponse == OuiNonInconnu.oui && z.id == sg1.zoneId ? NiveauRisque.rouge : NiveauRisque.orange),
            ],
            signalements: d.signalements,
            positionVous: d.positionVous,
            signalementActifId: sg1.id,
            tronconsConfirmes: {if (_reponse == OuiNonInconnu.oui) sg1.id},
          ),
        ),
        _Section('SosHoldButton', actions: [
          TextButton(onPressed: () => setState(() => _sosEnvoye = false), child: const Text('Réinitialiser')),
        ]),
        Center(child: SosHoldButton(onComplete: () => setState(() => _sosEnvoye = true))),
        const _Section('SosStatusTimeline'),
        _pad(SosStatusTimeline(
          etapes: [
            for (final (i, e) in d.sosCourant.timeline.indexed)
              EtapeSos(etape: e.etape, detail: e.detail, fait: i == 0 ? _sosEnvoye : e.fait && _sosEnvoye),
          ],
        )),
        const _Section('StatusChip — appuyer pour avancer'),
        _pad(Row(children: [StatusChip(statut: _statut, onTap: () => setState(() => _statut = _statut.suivant))])),
      ],
    );
  }

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: HydroticSpacing.screenPadding),
        child: child,
      );
}

class _Section extends StatelessWidget {
  const _Section(this.titre, {this.padded = true, this.actions = const []});

  final String titre;
  final bool padded;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(HydroticSpacing.screenPadding, padded ? 20 : 8, 8, 8),
      child: Row(
        children: [
          Expanded(child: Text(titre, style: HydroticText.sectionTitle.copyWith(color: HydroticColors.slateDark))),
          ...actions,
        ],
      ),
    );
  }
}
