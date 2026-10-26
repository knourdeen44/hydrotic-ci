import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/l10n/fr.dart';
import 'package:hydrotic_ci/widgets/map/svg_path.dart';

void main() {
  test('parseSvgPath lit les contours des fixtures', () {
    final zone = parseSvgPath('M60 180 C110 200 150 300 140 380 C130 440 70 450 40 390 C10 330 20 200 60 180Z');
    final bounds = zone.getBounds();
    expect(bounds.left, greaterThanOrEqualTo(10));
    expect(bounds.bottom, lessThanOrEqualTo(450));

    final eau = parseSvgPath('M0 120 C80 140 120 90 200 130 S320 160 340 140 L340 0 L0 0Z');
    expect(eau.getBounds().right, 340);

    final route = parseSvgPath('M-10 260 L360 300');
    expect(route.getBounds().left, -10);
  });

  test('textes : question, votes et décimales', () {
    expect(Fr.questionRue('Rue Ministre'), 'La rue Ministre est-elle toujours inondée$nbsp?');
    expect(Fr.votes(7, 1), '7 «${nbsp}oui$nbsp» · 1 «${nbsp}non$nbsp»');
    expect(Fr.votreFiabilite(1.2), 'Votre fiabilité$nbsp: 1,2');
  });
}
