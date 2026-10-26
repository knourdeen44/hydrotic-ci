import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/hydrotic_sheet.dart';
import '../../widgets/toast.dart';

/// Numéro ajouté à l'adresse : relance un scénario même si son écran est déjà affiché.
int _lancement = 0;

String _scenario(String chemin, String demo) => '$chemin?demo=$demo&n=${++_lancement}';

/// Remet les données fictives et les choix locaux dans leur état de départ.
void reinitialiserDemo(BuildContext context) {
  ProviderScope.containerOf(context, listen: false)
    // Nouveaux dépôts « mock » : les signalements ajoutés localement disparaissent.
    ..invalidate(fixtureLoaderProvider)
    ..invalidate(confirmationsProvider)
    ..invalidate(choixZonesProvider)
    ..invalidate(canauxProvider)
    ..invalidate(zoneActiveProvider);
}

/// Menu caché du mode démo (appui long d'une seconde sur le logo).
Future<void> showDemoMenu(BuildContext context) {
  final entrees = <(String, IconData, void Function())>[
    (Fr.scenario1, Icons.notifications_active_rounded, () => context.go(_scenario('/', 'alerte'))),
    (
      Fr.scenario2,
      Icons.where_to_vote_rounded,
      () {
        ProviderScope.containerOf(context, listen: false).invalidate(confirmationsProvider);
        context.go(_scenario('/carte', 'confirmation'));
      },
    ),
    (Fr.scenario3, Icons.sos_rounded, () => context.go(_scenario('/sos', 'sos'))),
    (Fr.scenario4, Icons.dashboard_rounded, () => showToast(context, Fr.scenario4Mobile)),
    (Fr.apercuVerrouille, Icons.lock_clock_rounded, () => context.go('/demo/verrouille')),
    (
      Fr.reinitialiser,
      Icons.restart_alt_rounded,
      () {
        reinitialiserDemo(context);
        context.go('/');
      },
    ),
  ];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (menu) => HydroticSheet(
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Fr.modeDemoTitre, style: HydroticText.sheetTitle.copyWith(color: HydroticColors.gray)),
          const SizedBox(height: 8),
          for (final (label, icon, action) in entrees)
            _Entree(
              label: label,
              icon: icon,
              onTap: () {
                Navigator.of(menu).pop();
                action();
              },
            ),
        ],
      ),
    ),
  );
}

class _Entree extends StatelessWidget {
  const _Entree({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HydroticRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: HydroticSizes.touchTarget + 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: HydroticColors.slate),
            const SizedBox(width: HydroticSpacing.gapL),
            Expanded(child: Text(label, style: HydroticText.button.copyWith(color: HydroticColors.gray))),
          ],
        ),
      ),
    );
  }
}
