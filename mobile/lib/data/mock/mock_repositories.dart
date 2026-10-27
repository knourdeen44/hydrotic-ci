import '../models/alerte.dart';
import '../models/confirmation.dart';
import '../models/niveau_risque.dart';
import '../models/point_svg.dart';
import '../models/risque.dart';
import '../models/signalement.dart';
import '../models/sos.dart';
import '../models/utilisateur.dart';
import '../models/zone.dart';
import '../repositories.dart';
import 'fixture_loader.dart';

// Dépôts « mock » : lisent les fixtures, sans réseau. Les modifications restent en mémoire.

typedef _Json = Map<String, dynamic>;

class MockZoneRepository implements ZoneRepository {
  MockZoneRepository(this._fixtures);

  final FixtureLoader _fixtures;

  @override
  Future<List<Zone>> zones() async {
    final json = await _fixtures.load('zones');
    return [for (final z in json['zones'] as List) Zone.fromJson(z as _Json)];
  }

  @override
  Future<Zone> zone(String id) async => (await zones()).firstWhere((z) => z.id == id);
}

class MockRiskRepository implements RiskRepository {
  MockRiskRepository(this._fixtures);

  final FixtureLoader _fixtures;

  Future<_Json> get _risk => _fixtures.load('risk');

  @override
  Future<Map<NiveauRisque, NiveauInfo>> niveaux() async {
    final niveaux = (await _risk)['niveaux'] as _Json;
    return {
      for (final e in niveaux.entries) NiveauRisque.fromJson(e.key): NiveauInfo.fromJson(e.value as _Json),
    };
  }

  @override
  Future<RisqueZone> risqueZone(String zoneId) async {
    final parZone = (await _risk)['parZone'] as _Json;
    return RisqueZone.fromJson(zoneId, parZone[zoneId] as _Json);
  }

  @override
  Future<List<PluieJour>> pluie([String? zoneId]) async {
    final pluie = (await _risk)['pluie'] as _Json;
    final labels = (pluie['labels'] as List).cast<String>();
    final mm = (pluie['mm'] as List).cast<num>();
    final prevision = (pluie['prevision'] as List).cast<bool>();
    return [
      for (var i = 0; i < labels.length; i++)
        PluieJour(label: labels[i], mm: mm[i].toDouble(), prevision: prevision[i]),
    ];
  }

  @override
  Future<List<String>> consignes(NiveauRisque niveau) async {
    final consignes = (await _risk)['consignes'] as _Json;
    return ((consignes[niveau.name] as List?) ?? const []).cast<String>();
  }
}

class MockAlertRepository implements AlertRepository {
  MockAlertRepository(this._fixtures);

  final FixtureLoader _fixtures;

  @override
  Future<List<Alerte>> alertes() async {
    final json = await _fixtures.load('alerts');
    return [for (final a in json['alertes'] as List) Alerte.fromJson(a as _Json)];
  }

  @override
  Future<Alerte> alerte(String id) async => (await alertes()).firstWhere((a) => a.id == id);

  @override
  Future<Map<String, String>> modeles() async {
    final json = await _fixtures.load('alerts');
    return (json['modeles'] as _Json).cast<String, String>();
  }
}

class MockReportRepository implements ReportRepository {
  MockReportRepository(this._fixtures);

  final FixtureLoader _fixtures;

  /// Signalements ajoutés localement (écran M7).
  final List<Signalement> _ajouts = [];

  @override
  Future<List<Signalement>> signalements() async {
    final json = await _fixtures.load('reports');
    return [
      for (final s in json['signalements'] as List) Signalement.fromJson(s as _Json),
      ..._ajouts,
    ];
  }

  @override
  Future<PointSvg> positionUtilisateur() async {
    final json = await _fixtures.load('reports');
    return PointSvg.fromJson((json['utilisateur'] as _Json)['svg'] as _Json);
  }

  @override
  Future<void> ajouter(Signalement signalement, {String? commentaire}) async => _ajouts.add(signalement);

  @override
  Future<void> confirmer(String signalementId, OuiNonInconnu reponse) async {}
}

class MockSosRepository implements SosRepository {
  MockSosRepository(this._fixtures);

  final FixtureLoader _fixtures;

  @override
  Future<SosCourant> sosCourant() async {
    final json = await _fixtures.load('sos');
    return SosCourant.fromJson(json['sosCourant'] as _Json);
  }

  @override
  Future<List<Sos>> liste() async {
    final json = await _fixtures.load('sos');
    return [for (final s in json['liste'] as List) Sos.fromJson(s as _Json)];
  }

  @override
  Future<SosCourant> envoyer(SosEnvoi envoi) => sosCourant();

  @override
  Future<SosCourant> suivre(String id) => sosCourant();
}

class MockUserRepository implements UserRepository {
  MockUserRepository(this._fixtures);

  final FixtureLoader _fixtures;

  @override
  Future<Utilisateur> citoyen() async =>
      Utilisateur.fromJson((await _fixtures.load('user'))['citoyen'] as _Json);

  @override
  Future<Utilisateur> agent() async =>
      Utilisateur.fromJson((await _fixtures.load('user'))['agent'] as _Json);

  @override
  Future<void> enregistrer({List<String>? zonesSuivies, Set<Canal>? canaux}) async {}
}
