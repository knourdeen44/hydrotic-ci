import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/accueil/accueil_screen.dart';
import 'screens/alertes/alertes_screen.dart';
import 'screens/carte/carte_screen.dart';
import 'screens/demarrage/demarrage_screen.dart';
import 'screens/dev/catalog_screen.dart';
import 'screens/dev/theme_preview_screen.dart';
import 'screens/profil/profil_screen.dart';
import 'screens/signaler/signaler_screen.dart';
import 'screens/sos/sos_screen.dart';

/// Scénario de démonstration demandé dans l'adresse (`?demo=alerte|confirmation|sos`).
/// Le menu caché du mode démo (étape 7) utilisera ces mêmes adresses.
String? _demo(GoRouterState state) => state.uri.queryParameters['demo'];

/// Onglets : pas d'animation de transition entre écrans principaux.
Page<void> _onglet(GoRouterState state, Widget child) => NoTransitionPage(key: state.pageKey, child: child);

/// L'application s'ouvre sur le démarrage (M0) ; « Commencer » mène à l'accueil.
GoRouter createRouter({String initialLocation = '/demarrage'}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              _onglet(state, AccueilScreen(scenarioAlerte: _demo(state) == 'alerte')),
        ),
        GoRoute(
          path: '/carte',
          pageBuilder: (context, state) =>
              _onglet(state, CarteScreen(scenario: _demo(state) == 'confirmation')),
        ),
        GoRoute(
          path: '/alertes',
          pageBuilder: (context, state) => _onglet(state, const AlertesScreen()),
        ),
        GoRoute(
          path: '/profil',
          pageBuilder: (context, state) => _onglet(state, const ProfilScreen()),
        ),
        GoRoute(path: '/signaler', builder: (context, state) => const SignalerScreen()),
        GoRoute(
          path: '/demarrage',
          builder: (context, state) => DemarrageScreen(
            etape: EtapeDemarrage.values.asNameMap()[state.uri.queryParameters['etape']] ??
                EtapeDemarrage.bienvenue,
            depuisProfil: state.uri.queryParameters['retour'] == 'profil',
          ),
        ),
        GoRoute(
          path: '/sos',
          builder: (context, state) => SosScreen(scenario: _demo(state) == 'sos'),
        ),
        GoRoute(path: '/dev/catalogue', builder: (context, state) => const CatalogScreen()),
        GoRoute(path: '/dev/theme', builder: (context, state) => const ThemePreviewScreen()),
      ],
    );
