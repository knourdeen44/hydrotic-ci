import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: HydroticApp()));
}

// Navigation provisoire : une seule route jusqu'à l'étape 5 (écrans M0 à M7).
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _InitPage()),
  ],
);

class HydroticApp extends StatelessWidget {
  const HydroticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hydrotic CI',
      debugShowCheckedModeBanner: false,
      // Thème provisoire : remplacé par hydrotic_theme.dart (généré) à l'étape 2.
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      routerConfig: _router,
    );
  }
}

// Page provisoire de l'étape 1 (initialisation).
class _InitPage extends StatelessWidget {
  const _InitPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_hydrotic_full.png', width: 160),
            const SizedBox(height: 16),
            const Text(
              'Hydrotic CI',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Initialisation terminée — étape 1.'),
          ],
        ),
      ),
    );
  }
}
