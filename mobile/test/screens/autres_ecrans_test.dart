import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/l10n/fr.dart';

import '../support/pump_app.dart';

void main() {
  group('M5 — Alertes', () {
    testWidgets("alerte en cours, historique des alertes envoyées, bulletins", (tester) async {
      await pumpApp(tester, '/alertes');
      expect(find.text('TREICHVILLE · MERCREDI 17 JUIN · 18:42'), findsOneWidget);
      expect(find.text('ALERTE ORANGE — Treichville'), findsOneWidget);
      expect(find.text('Vigilance jaune — Treichville'), findsOneWidget);
      // L'alerte rouge attend la validation des autorités : pas encore diffusée.
      expect(find.text('ALERTE ROUGE — Riviera Palmeraie'), findsNothing);
      await tester.scrollUntilVisible(find.text(Fr.bulletinsVide), 200);
      expect(find.text(Fr.bulletinsVide), findsOneWidget);
    });

    testWidgets('« Voir les consignes » ouvre la feuille', (tester) async {
      await pumpApp(tester, '/alertes');
      await tester.tap(find.text(Fr.voirConsignes));
      await tester.pumpAndSettle();
      expect(find.text(Fr.queFaireAvantDemain), findsOneWidget);
      expect(find.text('Consignes pour le niveau orange · Treichville'), findsOneWidget);
    });
  });

  group('M6 — Profil', () {
    testWidgets('identité, quartiers, canaux, fiabilité et mention démo', (tester) async {
      await pumpApp(tester, '/profil');
      expect(find.text('Awa'), findsOneWidget);
      expect(find.text('Citoyenne · Treichville'), findsOneWidget);
      expect(find.text('Riviera Palmeraie'), findsOneWidget);
      final email = find.byType(Switch).at(1);
      expect(tester.widget<Switch>(email).value, isTrue);
      await tester.tap(email);
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);
      // Alertes rouges : interrupteur non modifiable.
      expect(tester.widget<Switch>(find.byType(Switch).at(2)).onChanged, isNull);
      await tester.scrollUntilVisible(find.text(Fr.modeDemo), 200);
      expect(find.text('1,2'), findsOneWidget);
      expect(find.text(Fr.numerosACompleter), findsOneWidget);
    });

    testWidgets('« Modifier » ouvre le choix des quartiers puis revient', (tester) async {
      await pumpApp(tester, '/profil');
      await tester.tap(find.text(Fr.modifier));
      await tester.pumpAndSettle();
      expect(find.text(Fr.quelsQuartiers), findsOneWidget);
      await tester.tap(find.text('Riviera Palmeraie — Cocody'));
      await tester.pump();
      await tester.tap(find.text(Fr.continuer));
      await tester.pumpAndSettle();
      expect(find.text(Fr.mesQuartiers), findsOneWidget);
      expect(find.text('Riviera Palmeraie'), findsNothing);
    });
  });

  group('M7 — Signaler', () {
    testWidgets("hauteur d'eau obligatoire, puis envoi vers la carte", (tester) async {
      await pumpApp(tester, '/signaler');
      expect(find.text(Fr.signalerInondation), findsOneWidget);
      await tester.scrollUntilVisible(find.text(Fr.envoyerSignalement), 200);
      await tester.tap(find.text(Fr.envoyerSignalement));
      await tester.pumpAndSettle();
      expect(find.text(Fr.signalerInondation), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Genou'), -200);
      await tester.tap(find.text('Genou'));
      await tester.pump();
      await tester.scrollUntilVisible(find.text(Fr.envoyerSignalement), 200);
      await tester.tap(find.text(Fr.envoyerSignalement));
      await tester.pumpAndSettle();
      expect(find.text(Fr.merciVoisins), findsOneWidget);
      expect(find.text(Fr.questionRue('Rue Ministre')), findsOneWidget);
      await avancer(tester, const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('M0 — Démarrage', () {
    testWidgets('parcours complet jusqu\'à l\'accueil', (tester) async {
      await pumpApp(tester, '/demarrage');
      expect(find.text(Fr.nomApp), findsOneWidget);
      await tester.tap(find.text(Fr.creerCompte));
      await tester.pumpAndSettle();
      expect(find.text(Fr.inscription), findsOneWidget);
      expect(find.text(Fr.champEmail), findsOneWidget);
      expect(find.text(Fr.champMotDePasse), findsOneWidget);
      await tester.tap(find.text(Fr.continuer));
      await tester.pumpAndSettle();

      expect(find.text(Fr.quelsQuartiers), findsOneWidget);
      expect(find.text('Treichville'), findsOneWidget);
      await tester.tap(find.text('Riviera Palmeraie — Cocody'));
      await tester.pump();
      await tester.tap(find.text(Fr.continuer));
      await tester.pumpAndSettle();

      expect(find.text(Fr.autorisationNotifications), findsOneWidget);
      expect(find.text(Fr.autorisationLocalisation), findsOneWidget);
      await tester.scrollUntilVisible(find.text(Fr.commencer), 200);
      await tester.tap(find.text(Fr.commencer));
      await tester.pumpAndSettle();
      expect(find.text('Bonjour Awa'), findsOneWidget);
      expect(find.text('1 zone'), findsOneWidget);
    });

    testWidgets('aucun quartier coché : impossible de continuer', (tester) async {
      await pumpApp(tester, '/demarrage?etape=quartiers');
      await tester.tap(find.text('Treichville'));
      await tester.pump();
      await tester.tap(find.text('Riviera Palmeraie — Cocody'));
      await tester.pump();
      await tester.tap(find.text(Fr.continuer));
      await tester.pumpAndSettle();
      expect(find.text(Fr.quelsQuartiers), findsOneWidget);
    });
  });

  testWidgets('les onglets mènent aux écrans Alertes et Profil', (tester) async {
    await pumpApp(tester, '/');
    await tester.tap(find.text(Fr.navAlertes));
    await tester.pumpAndSettle();
    expect(find.text(Fr.historique), findsOneWidget);
    await tester.tap(find.text(Fr.navProfil));
    await tester.pumpAndSettle();
    expect(find.text(Fr.mesQuartiers), findsOneWidget);
  });
}
