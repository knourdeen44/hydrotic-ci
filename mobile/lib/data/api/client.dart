import 'dart:convert';

import 'package:http/http.dart' as http;

import '../mock/fixture_loader.dart';
import '../mode.dart';
import 'navigateur.dart';

/// Erreur renvoyée par l'API (message lisible dans `detail`).
class ErreurApi implements Exception {
  const ErreurApi(this.statut, this.message);

  final int statut;
  final String message;

  @override
  String toString() => message;
}

/// Client de l'API Hydrotic : seul endroit de l'application qui appelle le réseau.
class ApiClient {
  ApiClient([http.Client? client]) : _http = client ?? http.Client();

  final http.Client _http;

  Future<dynamic> get(String chemin) => _envoyer('GET', chemin);

  Future<dynamic> post(String chemin, Object corps) => _envoyer('POST', chemin, corps);

  Future<dynamic> patch(String chemin, Object corps) => _envoyer('PATCH', chemin, corps);

  Future<dynamic> _envoyer(String methode, String chemin, [Object? corps]) async {
    final jeton = await Navigateur.jeton();
    final requete = http.Request(methode, Uri.parse('$apiUrl$chemin'));
    if (jeton != null) requete.headers['Authorization'] = 'Bearer $jeton';
    if (corps != null) {
      requete.headers['Content-Type'] = 'application/json';
      requete.body = jsonEncode(corps);
    }
    final reponse = await http.Response.fromStream(await _http.send(requete));
    // Même typographie que les fixtures (espaces insécables).
    final texte = typographieFr(utf8.decode(reponse.bodyBytes));
    if (reponse.statusCode >= 400) {
      var detail = reponse.reasonPhrase ?? 'Erreur ${reponse.statusCode}';
      try {
        final json = jsonDecode(texte);
        if (json is Map && json['detail'] is String) detail = json['detail'] as String;
      } on FormatException {
        // Corps non JSON : on garde le texte du statut.
      }
      throw ErreurApi(reponse.statusCode, detail);
    }
    return texte.isEmpty ? null : jsonDecode(texte);
  }
}
