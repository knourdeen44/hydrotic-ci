@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/l10n/fr.dart';
import 'package:hydrotic_ci/main.dart';
import 'package:hydrotic_ci/widgets/sos_hold_button.dart';

import 'support/pump_app.dart';

// Captures de référence des écrans M1 à M4, à la taille utile de la maquette (340 × 720,
// barre d'état de 34 px), en Inter et avec les icônes Material.
// Générées en CI uniquement (rendu identique d'une exécution à l'autre) :
// workflow « Vérification et publication » lancé à la main avec « goldens » coché.

Future<void> _chargerPolices() async {
  ByteData lire(String chemin) => ByteData.sublistView(File(chemin).readAsBytesSync());

  final inter = FontLoader('Inter');
  for (final graisse in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
    inter.addFont(Future.value(lire('assets/fonts/Inter-$graisse.ttf')));
  }
  await inter.load();

  // Icônes Material : fournies par le SDK Flutter.
  final racines = [
    Platform.environment['FLUTTER_ROOT'],
    File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path,
  ];
  for (final racine in racines.whereType<String>()) {
    final icones = File('$racine/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icones.existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(Future.value(lire(icones.path)))).load();
      return;
    }
  }
}

Future<void> _capture(
  WidgetTester tester,
  String nom,
  String location, {
  Future<void> Function(WidgetTester tester)? action,
}) async {
  tester.view
    ..physicalSize = const Size(680, 1440)
    ..devicePixelRatio = 2
    ..padding = const FakeViewPadding(top: 68);
  addTearDown(tester.view.reset);

  // flutter_test dessine par défaut les ombres sans flou (bande grise) : on garde les vraies ombres.
  // Rétabli avant la fin du test (vérification des variables de débogage).
  debugDisableShadows = false;
  try {
    await pumpApp(tester, location);
    if (action != null) await action(tester);
    await tester.pumpAndSettle();

    // Les images (logos) se chargent hors du temps simulé.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pumpAndSettle();
    await expectLater(find.byType(HydroticApp), matchesGoldenFile('goldens/$nom.png'));
  } finally {
    debugDisableShadows = true;
  }
}

/// Capture pas encore générée : test ignoré (sauf en régénération).
bool _absente(String nom) => !autoUpdateGoldenFiles && !File('test/goldens/$nom.png').existsSync();

void main() {
  setUpAll(_chargerPolices);

  // Écrans sans maquette de référence dédiée (M0, M5 à M7, aperçu verrouillé) : non-régression.
  for (final (nom, location) in [
    ('m0_bienvenue', '/demarrage'),
    ('m0_quartiers', '/demarrage?etape=quartiers'),
    ('m0_autorisations', '/demarrage?etape=autorisations'),
    ('m5_alertes', '/alertes'),
    ('m6_profil', '/profil'),
    ('m7_signaler', '/signaler'),
    ('m2_ecran_verrouille', '/demo/verrouille'),
  ]) {
    testWidgets(nom, (tester) => _capture(tester, nom, location), skip: _absente(nom));
  }

  testWidgets('M1 accueil', (tester) => _capture(tester, 'm1_accueil', '/'));

  // Début du scénario 1 (vidéo v1_alerte) : carte jaune, avant la bannière.
  testWidgets('M1 accueil (début du scénario alerte)',
      (tester) => _capture(tester, 'm1_alerte_debut', '/?demo=alerte'),
      skip: _absente('m1_alerte_debut'));

  testWidgets('M2 alerte (fin)', (tester) => _capture(
        tester,
        'm2_alerte_fin',
        '/?demo=alerte',
        action: (t) => avancer(t, const Duration(seconds: 8)),
      ));

  testWidgets('M3 carte (question)', (tester) => _capture(tester, 'm3_carte_debut', '/carte'));

  testWidgets('M3 carte (merci)', (tester) => _capture(
        tester,
        'm3_carte_fin',
        '/carte',
        action: (t) async {
          await t.tap(find.text(Fr.oui));
          await avancer(t, const Duration(milliseconds: 1800));
        },
      ));

  testWidgets('M4 SOS (repos)', (tester) => _capture(tester, 'm4_sos_debut', '/sos'));

  testWidgets('M4 SOS (envoyé)', (tester) => _capture(
        tester,
        'm4_sos_fin',
        '/sos',
        action: (t) async {
          final geste = await t.startGesture(t.getCenter(find.byType(SosHoldButton)));
          await t.pump();
          await avancer(t, const Duration(milliseconds: 3100));
          await geste.up();
          await avancer(t, const Duration(seconds: 4));
        },
      ));
}
