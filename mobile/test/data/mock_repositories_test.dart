import 'package:flutter_test/flutter_test.dart';
import 'package:hydrotic_ci/data/mock/fixture_loader.dart';
import 'package:hydrotic_ci/data/mock/mock_repositories.dart';
import 'package:hydrotic_ci/data/models/alerte.dart';
import 'package:hydrotic_ci/data/models/niveau_risque.dart';
import 'package:hydrotic_ci/data/models/signalement.dart';
import 'package:hydrotic_ci/data/models/sos.dart';
import 'package:hydrotic_ci/data/models/utilisateur.dart';

import '../support/file_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FixtureLoader fixtures;

  setUp(() => fixtures = testFixtureLoader());

  test('zones', () async {
    final zones = await MockZoneRepository(fixtures).zones();
    expect(zones.map((z) => z.nom), ['Treichville', 'Riviera Palmeraie']);
    expect((await MockZoneRepository(fixtures).zone('palmeraie')).commune, 'Cocody');
  });

  test('risque', () async {
    final repo = MockRiskRepository(fixtures);
    expect((await repo.niveaux())[NiveauRisque.orange]!.label, 'Risque élevé');
    final treichville = await repo.risqueZone('treichville');
    expect(treichville.aujourdhui, NiveauRisque.jaune);
    expect(treichville.demain, NiveauRisque.orange);
    final pluie = await repo.pluie();
    expect(pluie, hasLength(7));
    expect(pluie.where((p) => p.prevision).map((p) => p.label), ['J+1', 'J+2']);
    expect(await repo.consignes(NiveauRisque.orange), hasLength(3));
    expect(await repo.consignes(NiveauRisque.vert), isEmpty);
  });

  test('alertes', () async {
    final repo = MockAlertRepository(fixtures);
    expect(await repo.alertes(), hasLength(3));
    final al2 = await repo.alerte('al-2');
    expect(al2.statut, StatutAlerte.enAttente);
    expect(al2.probabilite, 0.82);
    expect((await repo.modeles()).keys, contains('sosRecu'));
  });

  test('signalements et ajout local', () async {
    final repo = MockReportRepository(fixtures);
    final sg1 = (await repo.signalements()).first;
    expect(sg1.rue, 'Rue Ministre');
    expect(sg1.statut, StatutSignalement.aConfirmer);
    expect(sg1.apresOui!.oui, 8);
    expect((await repo.positionUtilisateur()).x, 200);
    await repo.ajouter(sg1.copyWith(statut: StatutSignalement.confirme));
    expect(await repo.signalements(), hasLength(4));
  });

  test('sos', () async {
    final repo = MockSosRepository(fixtures);
    final courant = await repo.sosCourant();
    expect(courant.timeline.map((e) => e.etape),
        ['Reçu par les secours', 'Équipe en route', 'Secouru']);
    final liste = await repo.liste();
    expect(liste.map((s) => s.statut),
        [StatutSos.recu, StatutSos.recu, StatutSos.enRoute, StatutSos.secouru]);
    expect(StatutSos.recu.suivant, StatutSos.enRoute);
    expect(StatutSos.secouru.suivant, StatutSos.secouru);
  });

  test('typographie française des fixtures', () async {
    final modeles = await MockAlertRepository(fixtures).modeles();
    expect(modeles['confirmation'], contains('inondée\u00A0?'));
    expect(typographieFr('« oui » : 8 %'), '«\u00A0oui\u00A0»\u00A0: 8\u00A0%');
  });

  test('utilisateurs', () async {
    final repo = MockUserRepository(fixtures);
    final awa = await repo.citoyen();
    expect(awa.nom, 'Awa');
    expect(awa.role, Role.citoyen);
    expect(awa.canauxPreferes, {Canal.push, Canal.email});
    expect((await repo.agent()).role, Role.agent);
  });
}
