import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/main.dart';

void main() {
  testWidgets('la page d\'initialisation affiche le nom de l\'application', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HydroticApp()));
    await tester.pumpAndSettle();
    expect(find.text('Hydrotic CI'), findsOneWidget);
  });
}
