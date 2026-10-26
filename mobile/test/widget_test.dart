import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/data/providers.dart';
import 'package:hydrotic_ci/l10n/fr.dart';
import 'package:hydrotic_ci/main.dart';

import 'support/file_asset_bundle.dart';
import 'support/pump_app.dart';

void main() {
  testWidgets("l'application s'ouvre sur le démarrage", (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [fixtureLoaderProvider.overrideWithValue(testFixtureLoader())],
      child: const HydroticApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text(Fr.creerCompte), findsOneWidget);
    expect(find.text(Fr.slogan), findsOneWidget);
  });

  testWidgets("l'accueil s'ouvre sur l'adresse /", (tester) async {
    await pumpApp(tester, '/');
    expect(find.text('Bonjour Awa'), findsOneWidget);
    expect(find.text('Risque élevé'), findsOneWidget);
  });

  testWidgets('le catalogue de développement reste accessible', (tester) async {
    await pumpApp(tester, '/dev/catalogue');
    expect(find.text('HydroticHeader'), findsOneWidget);
    // Laisse expirer les minuteries éventuelles (bannière de notification).
    await avancer(tester, const Duration(seconds: 4));
  });
}
