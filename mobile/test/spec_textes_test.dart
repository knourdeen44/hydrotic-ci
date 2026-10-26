import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/l10n/fr.dart';

/// Les textes composés à l'exécution (gabarit + données) doivent reproduire mot pour mot les
/// citations de docs/SPEC_UI.md. Comparaison sans distinguer espace insécable et espace simple.
/// (« Riviera Palmeraie — Cocody », composé depuis zones.json, est vérifié dans autres_ecrans_test.)
String _sansInsecable(String s) => s.replaceAll(nbsp, ' ');

void main() {
  final cas = <String, String>{
    // M1 (sur-titre affiché en majuscules ; {NIVEAU} = niveau de demain)
    'DEMAIN · NIVEAU {NIVEAU}': Fr.demainNiveau('{niveau}').toUpperCase(),
    '{n} confirmés': Fr.confirmes(3).replaceFirst('3', '{n}'),
    // M2
    'Consignes pour le niveau orange · Treichville': Fr.consignesPour('orange', 'Treichville'),
    // M3
    'La rue Ministre est-elle toujours inondée ?': Fr.questionRue('Rue Ministre'),
    'Vous êtes à 140 m. Votre réponse aide vos voisins et les secours.': Fr.vousEtesA('140 m'),
    'Signalé il y a 38 min': Fr.signaleIlYA('38 min'),
    '7 « oui » · 1 « non »': Fr.votes(7, 1),
    '8 « oui » · 1 « non »': Fr.votes(8, 1),
    'Rue Ministre : inondation confirmée par 8 habitants. Les autorités voient l\'information sur leur tableau de bord.':
        '${Fr.rueDeuxPoints('Rue Ministre')}${Fr.inondationConfirmee}${Fr.parHabitants(8)}',
    'Votre fiabilité : 1,2': Fr.votreFiabilite(1.2),
    // M4
    'Précision ± 12 m · Treichville, avenue 21': Fr.precision(12, 'Treichville, avenue 21'),
    // M6
    'Citoyenne · Treichville': Fr.identite('Treichville'),
  };

  for (final MapEntry(key: spec, value: compose) in cas.entries) {
    test('« $spec »', () => expect(_sansInsecable(compose), spec));
  }

  test('espaces insécables avant « : » et « ? »', () {
    expect(Fr.questionRue('Rue Ministre'), endsWith('$nbsp?'));
    expect(Fr.votreFiabilite(1.2), contains('$nbsp:'));
  });
}
