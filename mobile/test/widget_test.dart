import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/data/providers.dart';
import 'package:hydrotic_ci/main.dart';

import 'support/file_asset_bundle.dart';

void main() {
  testWidgets('le catalogue affiche les composants avec les données fictives', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [fixtureLoaderProvider.overrideWithValue(testFixtureLoader())],
      child: const HydroticApp(),
    ));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Bonjour Awa'), findsOneWidget);
    expect(find.text('2 zones'), findsOneWidget);
    // Laisse expirer les minuteries éventuelles (bannière de notification).
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
