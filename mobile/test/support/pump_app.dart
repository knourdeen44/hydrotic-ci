import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/data/providers.dart';
import 'package:hydrotic_ci/main.dart';

import 'file_asset_bundle.dart';

/// Lance l'application sur [location] avec les fixtures lues sur le disque.
Future<void> pumpApp(WidgetTester tester, String location) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [fixtureLoaderProvider.overrideWithValue(testFixtureLoader())],
    child: HydroticApp(initialLocation: location),
  ));
  await tester.pumpAndSettle();
}

/// Avance le temps simulé par pas de 100 ms (les animations ont besoin de frames).
Future<void> avancer(WidgetTester tester, Duration duree) async {
  const pas = Duration(milliseconds: 100);
  for (var t = Duration.zero; t < duree; t += pas) {
    await tester.pump(pas);
  }
}
