import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/l10n/fr.dart';
import 'package:hydrotic_ci/widgets/long_press_1s.dart';

import '../support/pump_app.dart';

/// Appui long d'une seconde sur le logo de l'accueil.
Future<void> ouvrirMenuDemo(WidgetTester tester) async {
  final geste = await tester.startGesture(tester.getCenter(find.byType(LongPress1s).first));
  await tester.pump(const Duration(milliseconds: 1100));
  await geste.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('un appui court ne suffit pas ; 1 s ouvre le menu démo', (tester) async {
    await pumpApp(tester, '/');
    final geste = await tester.startGesture(tester.getCenter(find.byType(LongPress1s).first));
    await tester.pump(const Duration(milliseconds: 600));
    await geste.up();
    await tester.pumpAndSettle();
    expect(find.text(Fr.modeDemoTitre), findsNothing);

    await ouvrirMenuDemo(tester);
    for (final entree in [
      Fr.scenario1,
      Fr.scenario2,
      Fr.scenario3,
      Fr.scenario4,
      Fr.apercuVerrouille,
      Fr.reinitialiser,
    ]) {
      expect(find.text(entree), findsOneWidget);
    }
  });

  testWidgets('scénario 1 relancé depuis l\'accueil : carte jaune puis bannière', (tester) async {
    await pumpApp(tester, '/');
    expect(find.text('DEMAIN · NIVEAU ORANGE'), findsOneWidget);
    await ouvrirMenuDemo(tester);
    await tester.tap(find.text(Fr.scenario1));
    await tester.pumpAndSettle();
    expect(find.text('DEMAIN · NIVEAU JAUNE'), findsOneWidget);
    await avancer(tester, const Duration(milliseconds: 2500));
    expect(find.text('ALERTE ORANGE — Treichville'), findsOneWidget);
    await avancer(tester, const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('scénario 3 : maintien simulé puis « SOS envoyé »', (tester) async {
    await pumpApp(tester, '/');
    await ouvrirMenuDemo(tester);
    await tester.tap(find.text(Fr.scenario3));
    await tester.pumpAndSettle();
    expect(find.text(Fr.besoinAide), findsOneWidget);
    await avancer(tester, const Duration(milliseconds: 5000));
    expect(find.text(Fr.sosEnvoye), findsOneWidget);
    await avancer(tester, const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('scénario 4 : renvoie au tableau de bord', (tester) async {
    await pumpApp(tester, '/');
    await ouvrirMenuDemo(tester);
    await tester.tap(find.text(Fr.scenario4));
    await tester.pump();
    expect(find.text(Fr.scenario4Mobile), findsOneWidget);
    await avancer(tester, const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('réinitialiser efface la réponse donnée sur la carte', (tester) async {
    await pumpApp(tester, '/carte');
    await tester.tap(find.text(Fr.oui));
    await avancer(tester, const Duration(milliseconds: 1500));
    await tester.tap(find.text(Fr.navAccueil));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Fr.navCarte).last); // onglet (aussi présent dans l'accès rapide)
    await tester.pumpAndSettle();
    // Réponse déjà donnée : plus de question.
    expect(find.text(Fr.questionRue('Rue Ministre')), findsNothing);

    await tester.tap(find.text(Fr.navAccueil));
    await tester.pumpAndSettle();
    await ouvrirMenuDemo(tester);
    await tester.tap(find.text(Fr.reinitialiser));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Fr.navCarte).last); // onglet (aussi présent dans l'accès rapide)
    await tester.pumpAndSettle();
    expect(find.text(Fr.questionRue('Rue Ministre')), findsOneWidget);
  });

  testWidgets('aperçu écran verrouillé (M2) : heure, alerte rouge, alerte de la veille', (tester) async {
    await pumpApp(tester, '/demo/verrouille');
    expect(find.text('05:17'), findsOneWidget);
    expect(find.text('Mercredi 17 juin'), findsOneWidget);
    expect(find.text('ALERTE ROUGE — Riviera Palmeraie'), findsOneWidget);
    expect(find.text(Fr.jeSuisEnDanger), findsOneWidget);
    expect(find.textContaining(Fr.ilYAHeures(6)), findsOneWidget);
    expect(find.textContaining('Vigilance jaune pour demain à Treichville.'), findsOneWidget);
    await tester.tap(find.text(Fr.jeSuisEnDanger));
    await tester.pumpAndSettle();
    expect(find.text(Fr.besoinAide), findsOneWidget);
  });
}
