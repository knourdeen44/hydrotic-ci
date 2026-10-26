import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/l10n/fr.dart';
import 'package:hydrotic_ci/widgets/sos_hold_button.dart';

import '../support/pump_app.dart';

void main() {
  group('M1 — Accueil', () {
    testWidgets('affiche le risque de demain et les données du jour', (tester) async {
      await pumpApp(tester, '/');
      expect(find.text('Bonjour Awa'), findsOneWidget);
      expect(find.text('Treichville · Avenue 21'), findsOneWidget);
      expect(find.text('DEMAIN · NIVEAU ORANGE'), findsOneWidget);
      expect(find.text('Risque élevé'), findsOneWidget);
      expect(find.text('Vigilance'), findsOneWidget);
      expect(find.text('3 confirmés'), findsOneWidget);
      expect(find.text(Fr.pluieTitre), findsOneWidget);
      expect(find.bySemanticsLabel(Fr.sosSemantique), findsOneWidget);
    });

    testWidgets('Consignes ouvre la feuille du niveau de demain', (tester) async {
      await pumpApp(tester, '/');
      await tester.tap(find.text(Fr.actionConsignes));
      await tester.pumpAndSettle();
      expect(find.text(Fr.queFaireAvantDemain), findsOneWidget);
      expect(find.text('Consignes pour le niveau orange · Treichville'), findsOneWidget);
    });

    testWidgets('la puce « 2 zones » bascule vers Riviera Palmeraie', (tester) async {
      await pumpApp(tester, '/');
      await tester.tap(find.text('2 zones'));
      await tester.pumpAndSettle();
      expect(find.text('Riviera Palmeraie · Cocody'), findsOneWidget);
      expect(find.text('Danger imminent'), findsOneWidget);
    });
  });

  testWidgets('M2 — scénario alerte : bannière, passage à l\'orange, consignes', (tester) async {
    await pumpApp(tester, '/?demo=alerte');
    expect(find.text('DEMAIN · NIVEAU JAUNE'), findsOneWidget);
    await avancer(tester, const Duration(milliseconds: 2500));
    expect(find.text('ALERTE ORANGE — Treichville'), findsOneWidget);
    await avancer(tester, const Duration(milliseconds: 4500));
    await tester.pumpAndSettle();
    expect(find.text('ALERTE ORANGE — Treichville'), findsNothing);
    expect(find.text('DEMAIN · NIVEAU ORANGE'), findsOneWidget);
    expect(find.text(Fr.queFaireAvantDemain), findsOneWidget);
  });

  testWidgets('M3 — scénario confirmation : pop 1 s, feuille 2 s, « Oui » 4,55 s, merci, zone rouge', (tester) async {
    await pumpApp(tester, '/carte?demo=confirmation');
    expect(find.text(Fr.questionRue('Rue Ministre')), findsNothing);
    await avancer(tester, const Duration(milliseconds: 2700));
    expect(find.text(Fr.questionRue('Rue Ministre')), findsOneWidget);
    await avancer(tester, const Duration(milliseconds: 2500));
    expect(find.text(Fr.merci), findsOneWidget);
    expect(find.text(Fr.votes(8, 1)), findsOneWidget);
    await avancer(tester, const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  group('M3 — Carte', () {
    testWidgets('« Oui » affiche le merci et met à jour les votes', (tester) async {
      await pumpApp(tester, '/carte');
      expect(find.text(Fr.questionRue('Rue Ministre')), findsOneWidget);
      expect(find.text(Fr.votes(7, 1)), findsOneWidget);
      // La feuille recouvre le bouton SOS tant qu'elle est ouverte.
      expect(find.bySemanticsLabel(Fr.sosSemantique), findsNothing);
      await tester.tap(find.text(Fr.oui));
      await avancer(tester, const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(find.text(Fr.merci), findsOneWidget);
      expect(find.text(Fr.votes(8, 1)), findsOneWidget);
      expect(find.text(Fr.votreFiabilite(1.2)), findsOneWidget);
    });

    testWidgets('« Non » : merci sans confirmation', (tester) async {
      await pumpApp(tester, '/carte');
      await tester.tap(find.text(Fr.non));
      await avancer(tester, const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(find.text(Fr.merci), findsOneWidget);
      expect(find.text(Fr.votes(7, 2)), findsOneWidget);
    });
  });

  group('M4 — SOS', () {
    testWidgets('repos : position, options modifiables, pas de bouton flottant', (tester) async {
      await pumpApp(tester, '/sos');
      expect(find.text(Fr.besoinAide), findsOneWidget);
      expect(find.text(Fr.positionTrouvee), findsOneWidget);
      expect(find.text(Fr.precision(12, 'Treichville, avenue 21')), findsOneWidget);
      expect(find.text('Genou'), findsOneWidget);
      await tester.tap(find.text('Genou'));
      await tester.pump();
      expect(find.text('Taille'), findsOneWidget);
      // Le seul bouton SOS est le bouton à maintenir.
      expect(find.bySemanticsLabel(Fr.sosSemantique), findsOneWidget);
    });

    testWidgets('maintien 3 s : SOS envoyé puis suivi', (tester) async {
      await pumpApp(tester, '/sos');
      final geste = await tester.startGesture(tester.getCenter(find.byType(SosHoldButton)));
      await tester.pump();
      await avancer(tester, const Duration(milliseconds: 3100));
      await geste.up();
      await avancer(tester, const Duration(milliseconds: 1000));
      expect(find.text(Fr.sosEnvoye), findsOneWidget);
      await avancer(tester, const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text(Fr.secoursInformes), findsOneWidget);
      expect(find.text('17:14 · ONPC — Lieutenant Traoré'), findsOneWidget);
    });

    testWidgets("repli SMS : message « prochaine version »", (tester) async {
      await pumpApp(tester, '/sos');
      await tester.ensureVisible(find.text(Fr.envoyerParSms));
      await tester.tap(find.text(Fr.envoyerParSms));
      await tester.pump();
      expect(find.text(Fr.bientot), findsOneWidget);
      await avancer(tester, const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}
