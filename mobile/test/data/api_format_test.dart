import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/data/api/format.dart';

void main() {
  test('dates de l’API mises en forme comme dans les fixtures', () {
    expect(dateAlerte('2026-06-17T18:42:00+00:00'), 'Mercredi 17 juin · 18:42');
    final maintenant = DateTime.utc(2026, 6, 17, 19, 20);
    expect(depuis('2026-06-17T18:42:00Z', maintenant), '38 min');
    expect(depuis('2026-06-17T17:20:00Z', maintenant), '2 h');
    expect(depuis('2026-06-15T19:20:00Z', maintenant), '2 j');
  });
}
