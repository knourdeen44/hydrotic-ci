// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

/// Objet `window.hydroticClerk` défini dans web/index.html (Clerk chargé par la page).
@JS('hydroticClerk')
external _Pont? get _pont;

extension type _Pont._(JSObject _) implements JSObject {
  external bool get demo;
  external JSPromise<JSBoolean> connecte();
  external JSPromise<JSString?> jeton();
  external JSPromise<JSBoolean> connecter(bool inscription);
  external JSPromise<JSAny?> deconnecter();
}

/// Connexion Clerk depuis la page web.
abstract final class Navigateur {
  static bool get demoDemande => _pont?.demo ?? true;

  static Future<bool> connecte() async => (await _pont?.connecte().toDart)?.toDart ?? false;

  static Future<String?> jeton() async => (await _pont?.jeton().toDart)?.toDart;

  /// Ouvre la fenêtre Clerk (inscription ou connexion) ; vrai une fois connecté.
  static Future<bool> connecter({required bool inscription}) async =>
      (await _pont?.connecter(inscription).toDart)?.toDart ?? false;

  static Future<void> deconnecter() async => await _pont?.deconnecter().toDart;
}
