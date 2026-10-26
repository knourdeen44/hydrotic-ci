import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/data/models/confirmation.dart';
import 'package:hydrotic_ci/data/models/niveau_risque.dart';
import 'package:hydrotic_ci/data/models/point_svg.dart';
import 'package:hydrotic_ci/data/models/risque.dart';
import 'package:hydrotic_ci/data/models/signalement.dart';
import 'package:hydrotic_ci/data/models/sos.dart';
import 'package:hydrotic_ci/data/models/zone.dart';
import 'package:hydrotic_ci/l10n/fr.dart';
import 'package:hydrotic_ci/theme/hydrotic_theme.dart';
import 'package:hydrotic_ci/widgets/bottom_nav.dart';
import 'package:hydrotic_ci/widgets/confirm_question_sheet.dart';
import 'package:hydrotic_ci/widgets/consignes_sheet.dart';
import 'package:hydrotic_ci/widgets/hydrotic_header.dart';
import 'package:hydrotic_ci/widgets/mini_stat.dart';
import 'package:hydrotic_ci/widgets/notification_banner.dart';
import 'package:hydrotic_ci/widgets/quick_actions.dart';
import 'package:hydrotic_ci/widgets/rain_bars.dart';
import 'package:hydrotic_ci/widgets/risk_card.dart';
import 'package:hydrotic_ci/widgets/schematic_map.dart';
import 'package:hydrotic_ci/widgets/sos_fab.dart';
import 'package:hydrotic_ci/widgets/sos_hold_button.dart';
import 'package:hydrotic_ci/widgets/sos_status_timeline.dart';
import 'package:hydrotic_ci/widgets/status_chip.dart';

Widget _wrap(Widget child) => MaterialApp(theme: HydroticTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('HydroticHeader : salutation, quartier et puce des zones', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(HydroticHeader(
      prenom: 'Awa',
      quartier: 'Treichville · Avenue 21',
      nbZones: 2,
      onZonesTap: () => taps++,
    )));
    expect(find.text('Bonjour Awa'), findsOneWidget);
    expect(find.text('Treichville · Avenue 21'), findsOneWidget);
    await tester.tap(find.text('2 zones'));
    expect(taps, 1);
  });

  testWidgets('RiskCard : sur-titre en majuscules et fondu au changement de niveau', (tester) async {
    Widget card(NiveauRisque n, String titre) =>
        _wrap(RiskCard(niveau: n, surTitre: Fr.demainNiveau(n.name), titre: titre, message: 'm'));
    await tester.pumpWidget(card(NiveauRisque.jaune, 'Vigilance'));
    expect(find.text('DEMAIN · NIVEAU JAUNE'), findsOneWidget);
    await tester.pumpWidget(card(NiveauRisque.orange, 'Risque élevé'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Vigilance'), findsOneWidget);
    expect(find.text('Risque élevé'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Vigilance'), findsNothing);
  });

  testWidgets('MiniStat et RainBars', (tester) async {
    const jours = [
      PluieJour(label: 'J-1', mm: 13, prevision: false),
      PluieJour(label: 'J+1', mm: 25, prevision: true),
    ];
    await tester.pumpWidget(_wrap(const Column(children: [
      MiniStat(label: Fr.aujourdhui, value: 'Vigilance', dotColor: Colors.amber),
      RainBars(jours: jours),
    ])));
    expect(find.text("Aujourd'hui"), findsOneWidget);
    expect(find.text('J+1'), findsOneWidget);
  });

  testWidgets('QuickActions et BottomNav déclenchent leurs actions', (tester) async {
    String? action;
    HydroticTab? onglet;
    await tester.pumpWidget(_wrap(Column(children: [
      QuickActions(onSignaler: () => action = 'signaler'),
      const Spacer(),
      BottomNav(current: HydroticTab.accueil, onTap: (t) => onglet = t),
    ])));
    await tester.tap(find.text(Fr.actionSignaler));
    await tester.tap(find.text(Fr.navAlertes));
    expect(action, 'signaler');
    expect(onglet, HydroticTab.alertes);
  });

  testWidgets('SosFab annonce le libellé d\'accessibilité', (tester) async {
    await tester.pumpWidget(_wrap(Center(child: SosFab(onPressed: () {}))));
    expect(find.bySemanticsLabel(Fr.sosSemantique), findsOneWidget);
  });

  testWidgets('NotificationBanner entre, reste 2,5 s puis ressort', (tester) async {
    var sortie = false;
    await tester.pumpWidget(_wrap(NotificationBanner(
      titre: 'ALERTE ORANGE — Treichville',
      titreColor: Colors.orange,
      corps: 'corps',
      onDismissed: () => sortie = true,
    )));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 2400));
    expect(sortie, isFalse);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(sortie, isTrue);
  });

  testWidgets('ConsignesSheet numérote les consignes', (tester) async {
    await tester.pumpWidget(_wrap(const ConsignesSheet(
      animate: false,
      titre: Fr.queFaireAvantDemain,
      sousTitre: 'Consignes pour le niveau orange · Treichville',
      consignes: ['a', 'b', 'c'],
      niveau: NiveauRisque.orange,
    )));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
  });

  testWidgets('ConfirmQuestionSheet : réponse puis état « Merci »', (tester) async {
    OuiNonInconnu? reponse;
    Widget sheet({MerciContenu? merci}) => _wrap(ConfirmQuestionSheet(
          animate: false,
          question: Fr.questionRue('Rue Ministre'),
          sousTitre: Fr.vousEtesA('140 m'),
          metaGauche: Fr.signaleIlYA('38 min'),
          metaDroite: Fr.votes(7, 1),
          onReponse: (r) => reponse = r,
          merci: merci,
        ));
    await tester.pumpWidget(sheet());
    expect(find.text('La rue Ministre est-elle toujours inondée$nbsp?'), findsOneWidget);
    await tester.tap(find.text(Fr.oui));
    expect(reponse, OuiNonInconnu.oui);
    await tester.pumpWidget(sheet(
      merci: const MerciContenu(message: TextSpan(text: 'ok'), metaGauche: 'g', metaDroite: 'd'),
    ));
    await tester.pumpAndSettle();
    expect(find.text(Fr.merci), findsOneWidget);
    expect(find.text(Fr.oui), findsNothing);
  });

  testWidgets('SosHoldButton : relâché avant 3 s, rien ; maintenu 3 s, envoyé', (tester) async {
    var envoye = false;
    await tester.pumpWidget(_wrap(Center(child: SosHoldButton(onComplete: () => envoye = true))));
    final centre = tester.getCenter(find.byType(SosHoldButton));

    var geste = await tester.startGesture(centre);
    await tester.pump(const Duration(seconds: 1));
    await geste.up();
    await tester.pumpAndSettle();
    expect(envoye, isFalse);

    geste = await tester.startGesture(centre);
    // Première frame : le ticker démarre ici (temps écoulé = 0).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2900));
    expect(envoye, isFalse);
    await tester.pump(const Duration(milliseconds: 150));
    expect(envoye, isTrue);
    await geste.up();
    await tester.pumpAndSettle();
  });

  testWidgets('SosStatusTimeline et StatusChip', (tester) async {
    var statut = StatutSos.recu;
    await tester.pumpWidget(_wrap(StatefulBuilder(
      builder: (context, setState) => Column(children: [
        const SosStatusTimeline(etapes: [
          EtapeSos(etape: 'Reçu par les secours', detail: '17:12', fait: true),
          EtapeSos(etape: 'Équipe en route', detail: '17:14', fait: false),
          EtapeSos(etape: 'Secouru', detail: '', fait: false),
        ]),
        StatusChip(statut: statut, onTap: () => setState(() => statut = statut.suivant)),
      ]),
    )));
    expect(find.text('Équipe en route'), findsOneWidget);
    await tester.tap(find.text(Fr.statutRecu));
    await tester.pump();
    expect(find.text(Fr.statutEnRoute), findsOneWidget);
  });

  testWidgets('SchematicMap : légende et changement de niveau sans erreur', (tester) async {
    const zone = Zone(
      id: 'palmeraie',
      nom: 'Riviera Palmeraie',
      commune: 'Cocody',
      profil: '',
      sousZones: [],
      svgMobile: 'M170 210 C230 200 290 250 280 330 C270 390 200 380 180 330Z',
      svgDashboard: '',
    );
    const signalement = Signalement(
      id: 'sg-1',
      zoneId: 'palmeraie',
      rue: 'Rue Ministre',
      statut: StatutSignalement.aConfirmer,
      oui: 7,
      non: 1,
      il: '38 min',
      position: PointSvg(160, 278),
      svgTroncon: 'M141 255 L178 300',
      svgEtiquette: PointSvg(186, 236),
    );
    Widget map(NiveauRisque n, Set<String> troncons) => _wrap(SchematicMap(
          zones: [(zone: zone, niveau: n)],
          signalements: const [signalement],
          positionVous: const PointSvg(200, 350),
          signalementActifId: 'sg-1',
          tronconsConfirmes: troncons,
        ));
    await tester.pumpWidget(map(NiveauRisque.orange, const {}));
    await tester.pumpAndSettle();
    expect(find.text(Fr.legendeInonde), findsOneWidget);
    await tester.pumpWidget(map(NiveauRisque.rouge, const {'sg-1'}));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
