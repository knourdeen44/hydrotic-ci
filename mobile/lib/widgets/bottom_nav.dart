import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Onglets de l'application citoyenne.
enum HydroticTab {
  accueil(Fr.navAccueil, Icons.home_rounded),
  carte(Fr.navCarte, Icons.map_rounded),
  alertes(Fr.navAlertes, Icons.notifications_rounded),
  profil(Fr.navProfil, Icons.person_rounded);

  const HydroticTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Barre de navigation du bas (prototype : `.nav`).
class BottomNav extends StatelessWidget {
  const BottomNav({super.key, this.current, required this.onTap});

  /// Onglet actif (aucun sur l'écran SOS).
  final HydroticTab? current;
  final ValueChanged<HydroticTab> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HydroticSizes.bottomNav,
      decoration: const BoxDecoration(
        color: HydroticColors.white,
        border: Border(top: BorderSide(color: HydroticColors.slateLight)),
      ),
      child: Row(
        children: [
          for (final tab in HydroticTab.values)
            Expanded(child: _NavItem(tab: tab, active: tab == current, onTap: () => onTap(tab))),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.active, required this.onTap});

  final HydroticTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // L'icône remplace le carré de 22 px du prototype (inactif : grayLight, pour le contraste).
            Icon(tab.icon, size: 22, color: active ? HydroticColors.slate : HydroticColors.grayLight),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: active
                  ? HydroticText.navLabelActive.copyWith(color: HydroticColors.slateDark)
                  : HydroticText.navLabel.copyWith(color: HydroticColors.grayLight),
            ),
          ],
        ),
      ),
    );
  }
}
