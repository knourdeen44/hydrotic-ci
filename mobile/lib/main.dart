import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/dev/theme_preview_screen.dart';
import 'theme/hydrotic_theme.dart';

void main() {
  runApp(const ProviderScope(child: HydroticApp()));
}

// Navigation provisoire : une seule route jusqu'à l'étape 5 (écrans M0 à M7).
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const ThemePreviewScreen()),
  ],
);

class HydroticApp extends StatelessWidget {
  const HydroticApp({super.key});

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
