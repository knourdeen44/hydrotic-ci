import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'state/session.dart';
import 'theme/hydrotic_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mode réel : session Clerk lue avant le premier écran (connecté : accueil ; sinon : démarrage).
  await initialiserSession();
  runApp(ProviderScope(child: HydroticApp(initialLocation: session.value ? '/' : '/demarrage')));
}

class HydroticApp extends StatefulWidget {
  const HydroticApp({super.key, this.initialLocation = '/demarrage'});

  /// Écran de départ (les tests ouvrent directement un écran).
  final String initialLocation;

  @override
  State<HydroticApp> createState() => _HydroticAppState();
}

class _HydroticAppState extends State<HydroticApp> {
  late final GoRouter _router = createRouter(initialLocation: widget.initialLocation);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hydrotic CI',
      debugShowCheckedModeBanner: false,
      theme: HydroticTheme.light,
      routerConfig: _router,
    );
  }
}
