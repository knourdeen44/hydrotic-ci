import 'api/navigateur.dart';

/// Adresse de l'API Hydrotic (`--dart-define=API_URL=…`). Vide : données fictives.
const apiUrl = String.fromEnvironment('API_URL');

/// Mode réel : API configurée et mode démo non demandé (menu du tableau de bord ou lien de scénario).
/// Sinon, mode démo : fixtures, aucun appel réseau (tests, captures, scénarios).
final bool modeApi = apiUrl.isNotEmpty && !Navigateur.demoDemande;
