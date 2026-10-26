import 'package:flutter_test/flutter_test.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets("l'application s'ouvre sur l'accueil", (tester) async {
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
