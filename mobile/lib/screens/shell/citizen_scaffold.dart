import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/sos_fab.dart';

/// Gabarit commun de l'application citoyenne : contenu, barre de navigation, bouton SOS
/// (18 px du bord droit, 16 px au-dessus de la barre) et calques (bannière, feuilles).
class CitizenScaffold extends StatelessWidget {
  const CitizenScaffold({
    super.key,
    required this.body,
    this.tab,
    this.showSosFab = true,
    this.overlays = const [],
  });

  final Widget body;

  /// Onglet actif (aucun sur l'écran SOS).
  final HydroticTab? tab;
  final bool showSosFab;

  /// Calques au-dessus du contenu, à positionner (ex. [Positioned] pour une feuille).
  final List<Widget> overlays;

  /// Bas des feuilles : juste au-dessus de la barre de navigation.
  static const double sheetBottom = HydroticSizes.bottomNav;

  static void goToTab(BuildContext context, HydroticTab tab) {
    switch (tab) {
      case HydroticTab.accueil:
        context.go('/');
      case HydroticTab.carte:
        context.go('/carte');
      case HydroticTab.alertes:
        context.go('/alertes');
      case HydroticTab.profil:
        context.go('/profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HydroticColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: body),
                BottomNav(current: tab, onTap: (t) => goToTab(context, t)),
              ],
            ),
            if (showSosFab)
              Positioned(
                right: SosFab.right,
                bottom: HydroticSizes.bottomNav + SosFab.gapAboveNav,
                child: SosFab(onPressed: () => context.push('/sos')),
              ),
            ...overlays,
          ],
        ),
      ),
    );
  }
}
