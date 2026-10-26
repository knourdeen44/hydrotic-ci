import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/hydrotic_theme.dart';

void main() {
  runApp(const ProviderScope(child: HydroticApp()));
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
