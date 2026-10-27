import '../../l10n/fr.dart';
import '../models/alerte.dart';
import '../models/confirmation.dart';
import '../models/geo.dart';
import '../models/niveau_risque.dart';
import '../models/point_svg.dart';
import '../models/risque.dart';
import '../models/signalement.dart';
import '../models/sos.dart';
import '../models/utilisateur.dart';
import '../models/zone.dart';
import '../position.dart';
import '../repositories.dart';
import 'client.dart';
import 'format.dart';

// Dépôts du mode réel : API Hydrotic (FastAPI + Neon), jeton Clerk du citoyen connecté.

typedef _Json = Map<String, dynamic>;

/// Lecture de la position GPS (autorisation demandée par le navigateur).
typedef LirePosition = Future<PositionGps?> Function();

class ApiZoneRepository implements ZoneRepository {
  ApiZoneRepository(this._api);

  final ApiClient _api;
  Future<List<Zone>>? _zones;

  @override
  Future<List<Zone>> zones() => _zones ??= _charger();

  Future<List<Zone>> _charger() async =>
      [for (final z in await _api.get('/api/zones') as List) Zone.fromJson(z as _Json)];

  @override
  Future<Zone> zone(String id) async => (await zones()).firstWhere((z) => z.id == id);
}

class ApiRiskRepository implements RiskRepository {
  ApiRiskRepository(this._api);

  final ApiClient _api;

  @override
  Future<Map<NiveauRisque, NiveauInfo>> niveaux() async {
    final json = await _api.get('/api/niveaux') as _Json;
    return {
      for (final e in json.entries) NiveauRisque.fromJson(e.key): NiveauInfo.fromJson(e.value as _Json),
    };
  }

  @override
  Future<RisqueZone> risqueZone(String zoneId) async {
    final r = await _api.get('/api/zones/$zoneId/risque') as _Json;
    final majLe = r['majLe'] as String?;
    return RisqueZone(
      zoneId: zoneId,
      aujourdhui: NiveauRisque.fromJson(r['aujourdhui'] as String),
      demain: NiveauRisque.fromJson(r['demain'] as String),
      signalementsConfirmes: r['signalementsConfirmes'] as int,
      majIl: majLe == null ? '—' : depuis(majLe),
    );
  }

  @override
  Future<List<PluieJour>> pluie([String? zoneId]) async {
    final json = await _api.get('/api/zones/${zoneId ?? 'treichville'}/pluie') as _Json;
    return [
      for (final j in json['jours'] as List)
        PluieJour(
          label: (j as _Json)['label'] as String,
          mm: (j['mm'] as num).toDouble(),
          prevision: j['prevision'] as bool,
        ),
    ];
  }

  @override
  Future<List<String>> consignes(NiveauRisque niveau) async =>
      (await _api.get('/api/consignes/${niveau.name}') as List).cast<String>();
}

class ApiAlertRepository implements AlertRepository {
  ApiAlertRepository(this._api, this._fixtures);

  final ApiClient _api;

  /// Modèles de messages : textes fixes des fixtures.
  final AlertRepository _fixtures;

  @override
  Future<List<Alerte>> alertes() async =>
      [for (final a in await _api.get('/api/alertes') as List) _alerte(a as _Json)];

  static Alerte _alerte(_Json a) => Alerte(
        id: a['id'] as String,
        zoneId: a['zoneId'] as String,
        niveau: NiveauRisque.fromJson(a['niveau'] as String),
        titre: a['titre'] as String,
        corps: a['corps'] as String,
        statut: StatutAlerte.fromJson(a['statut'] as String),
        date: dateAlerte(a['creeLe'] as String),
        source: a['source'] as String? ?? '',
        probabilite: (a['probabilite'] as num?)?.toDouble(),
        signalementsConfirmes: a['signalementsConfirmes'] as int?,
      );

  @override
  Future<Alerte> alerte(String id) async => (await alertes()).firstWhere((a) => a.id == id);

  @override
  Future<Map<String, String>> modeles() => _fixtures.modeles();
}

class ApiReportRepository implements ReportRepository {
  ApiReportRepository(this._api, this._position);

  final ApiClient _api;
  final LirePosition _position;

  /// Au-delà, aucune demande de confirmation n'est faite à l'habitant.
  static const _rayonConfirmationM = 1000;

  @override
  Future<List<Signalement>> signalements() async {
    final gps = await _position();
    final requete = gps == null ? '' : '?lat=${gps.geo.lat}&lon=${gps.geo.lon}';
    return [for (final s in await _api.get('/api/signalements$requete') as List) _signalement(s as _Json)];
  }

  static Signalement _signalement(_Json s) {
    final svg = s['svg'] as _Json?;
    final etiquette = s['svgEtiquette'] as _Json?;
    final distance = (s['distanceM'] as num?)?.round();
    final reponse = s['maReponse'] as String?;
    final auteur = s['estAuteur'] as bool? ?? false;
    final aConfirmer = distance != null && distance <= _rayonConfirmationM && !auteur && reponse == null;
    return Signalement(
      id: s['id'] as String,
      zoneId: s['zoneId'] as String,
      rue: s['rue'] as String? ?? Fr.positionSignalee,
      statut: StatutSignalement.fromJson(s['statut'] as String),
      oui: s['oui'] as int,
      non: s['non'] as int,
      il: depuis(s['creeLe'] as String),
      position: svg == null ? const PointSvg(0, 0) : PointSvg.fromJson(svg),
      geo: geoDepuisJson(s['position']),
      // Demande de confirmation : signalement proche, d'un autre habitant, encore sans réponse.
      distanceUtilisateur: aConfirmer ? '$distance m' : null,
      hauteurEau: s['hauteurEau'] as String?,
      svgTroncon: s['svgTroncon'] as String?,
      svgEtiquette: etiquette == null ? null : PointSvg.fromJson(etiquette),
      estAuteur: auteur,
      maReponse: reponse == null ? null : OuiNonInconnu.values.byName(reponse),
    );
  }

  @override
  Future<PointSvg> positionUtilisateur() async => const PointSvg(0, 0);

  @override
  Future<void> ajouter(Signalement signalement, {String? commentaire}) async {
    final geo = signalement.geo ?? (await _position())?.geo;
    if (geo == null) throw const ErreurApi(0, Fr.positionIndisponible);
    await _api.post('/api/signalements', {
      'lat': geo.lat,
      'lon': geo.lon,
      'hauteurEau': signalement.hauteurEau,
      if (commentaire != null) 'description': commentaire,
    });
  }

  @override
  Future<void> confirmer(String signalementId, OuiNonInconnu reponse) async {
    final gps = await _position();
    await _api.post('/api/signalements/$signalementId/confirmations', {
      'reponse': reponse.name,
      if (gps != null) ...{'lat': gps.geo.lat, 'lon': gps.geo.lon},
    });
  }
}

class ApiSosRepository implements SosRepository {
  ApiSosRepository(this._api, this._position, this._fixtures);

  final ApiClient _api;
  final LirePosition _position;

  /// Libellés des étapes du suivi (« Reçu par les secours »…).
  final SosRepository _fixtures;

  Future<List<String>> _libelles() async => [for (final e in (await _fixtures.sosCourant()).timeline) e.etape];

  /// SOS prêt à partir : position GPS réelle, options par défaut.
  @override
  Future<SosCourant> sosCourant() async {
    final gps = await _position();
    return SosCourant(
      lieu: gps == null ? Fr.positionInconnue : Fr.positionGps,
      precisionM: (gps?.precisionM ?? 0).roundToDouble(),
      nbPersonnes: 1,
      blesses: false,
      hauteurEau: Fr.hauteurs.first,
      enfantsOuAges: false,
      timeline: [for (final l in await _libelles()) EtapeSos(etape: l, detail: '', fait: false)],
    );
  }

  @override
  Future<SosCourant> envoyer(SosEnvoi envoi) async {
    final geo = envoi.geo;
    final json = await _api.post('/api/sos', {
      if (geo != null) ...{'lat': geo.lat, 'lon': geo.lon},
      if (envoi.precisionM != null) 'precisionM': envoi.precisionM,
      'nbPersonnes': envoi.personnes,
      'blesses': envoi.blesses,
      'hauteurEau': envoi.hauteurEau,
      'enfantsOuAges': envoi.enfantsOuAges,
    }) as _Json;
    return _suivi(json);
  }

  @override
  Future<SosCourant> suivre(String id) async => _suivi(await _api.get('/api/sos/$id') as _Json);

  Future<SosCourant> _suivi(_Json s) async {
    final libelles = await _libelles();
    return SosCourant(
      id: s['id'] as String,
      lieu: s['lieu'] as String,
      precisionM: (s['precisionM'] as num?)?.toDouble() ?? 0,
      nbPersonnes: s['nbPersonnes'] as int,
      blesses: s['blesses'] as bool,
      hauteurEau: s['hauteurEau'] as String? ?? '',
      enfantsOuAges: s['enfantsOuAges'] as bool,
      timeline: [
        for (final (i, e) in (s['etapes'] as List).indexed)
          EtapeSos(etape: libelles[i], detail: (e as _Json)['detail'] as String? ?? '', fait: e['fait'] as bool),
      ],
    );
  }

  @override
  Future<List<Sos>> liste() => _fixtures.liste();
}

class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._api, this._zones);

  final ApiClient _api;
  final ZoneRepository _zones;

  @override
  Future<Utilisateur> citoyen() async {
    final u = await _api.get('/api/moi') as _Json;
    final suivies = (u['zonesSuivies'] as List? ?? const []).cast<String>();
    final email = u['email'] as String? ?? '';
    final nom = u['nom'] as String? ?? '';
    final canaux = u['canauxPreferes'];
    return Utilisateur(
      id: u['id'] as String,
      nom: nom.isNotEmpty ? nom : email.split('@').first,
      role: Role.fromJson(u['role'] as String),
      // Nouveau compte : premier quartier par défaut, à changer au démarrage ou dans le profil.
      zonesSuivies: suivies.isNotEmpty ? suivies : [(await _zones.zones()).first.id],
      canauxPreferes: canaux is Map
          ? {for (final c in Canal.values) if (canaux[c.name] == true) c}
          : {for (final c in (canaux as List? ?? const [])) Canal.values.byName(c as String)},
      scoreFiabilite: (u['scoreFiabilite'] as num?)?.toDouble(),
      service: u['service'] as String?,
    );
  }

  @override
  Future<Utilisateur> agent() => citoyen();

  @override
  Future<void> enregistrer({List<String>? zonesSuivies, Set<Canal>? canaux}) async {
    await _api.patch('/api/moi', {
      if (zonesSuivies != null) 'zonesSuivies': zonesSuivies,
      if (canaux != null) 'canauxPreferes': [for (final c in canaux) c.name],
    });
  }
}
