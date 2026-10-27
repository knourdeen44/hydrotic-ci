/// Hors navigateur : pas de connexion Clerk, données fictives.
abstract final class Navigateur {
  static bool get demoDemande => true;
  static Future<bool> connecte() async => false;
  static Future<String?> jeton() async => null;
  static Future<bool> connecter({required bool inscription}) async => false;
  static Future<void> deconnecter() async {}
}
