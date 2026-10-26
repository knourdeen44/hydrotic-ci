import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/alerte.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../theme/risk_colors.dart';

/// Alerte rouge reçue (al-2) et alerte précédente (al-3), comme dans la maquette.
final _alertesProvider = FutureProvider<(Alerte, Alerte)>((ref) async {
  final rouge = ref.watch(alerteProvider('al-2').future);
  final veille = ref.watch(alerteProvider('al-3').future);
  return (await rouge, await veille);
});

/// Heure d'une date affichée (« Mercredi 17 juin · 05:17 » → (« Mercredi 17 juin », 5 h 17)).
(String, int) _jourEtMinutes(String date) {
  final [jour, heure] = date.split(' · ');
  final [h, m] = heure.split(':').map(int.parse).toList();
  return (jour, h * 60 + m);
}

/// Aperçu de l'écran verrouillé à la réception d'une alerte (M2, maquette 01 écran 2).
/// Réservé au mode démo, pour la présentation.
class EcranVerrouilleScreen extends ConsumerWidget {
  const EcranVerrouilleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertes = ref.watch(_alertesProvider).valueOrNull;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-.17, -1),
            end: Alignment(.17, 1),
            colors: [HydroticColors.slateDark, HydroticColors.phoneFrame],
          ),
        ),
        child: SafeArea(
          child: alertes == null ? const SizedBox.expand() : _contenu(context, alertes.$1, alertes.$2),
        ),
      ),
    );
  }

  Widget _contenu(BuildContext context, Alerte alerte, Alerte precedente) {
    final (jour, minutes) = _jourEtMinutes(alerte.date);
    final (_, minutesVeille) = _jourEtMinutes(precedente.date);
    // Alerte précédente reçue la veille.
    final heures = ((minutes + 24 * 60 - minutesVeille) / 60).floor();
    final heure = '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
    const blanc = HydroticColors.white;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: HydroticSpacing.gapL),
      children: [
        const SizedBox(height: 30),
        Text(
          heure,
          textAlign: TextAlign.center,
          style: HydroticText.body.copyWith(color: blanc, fontSize: 62, height: 1.21),
        ),
        Text(
          jour,
          textAlign: TextAlign.center,
          style: HydroticText.button.copyWith(color: blanc.withValues(alpha: .85), fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: blanc.withValues(alpha: .93),
            borderRadius: BorderRadius.circular(HydroticRadius.chip),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo_hydrotic_icon.png', width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text(Fr.notificationEnTete, style: HydroticText.small.copyWith(color: HydroticColors.grayLight)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alerte.titre,
                style: HydroticText.button.copyWith(color: alerte.niveau.couleur, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(alerte.corps, style: HydroticText.body.copyWith(color: HydroticColors.gray)),
              const SizedBox(height: HydroticSpacing.gapL),
              Row(
                children: [
                  Expanded(
                    child: _Action(
                      label: Fr.voirConsignes,
                      fond: HydroticColors.slateLight,
                      texte: HydroticColors.slateDark,
                      onTap: () => context.go('/'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Action(
                      label: Fr.jeSuisEnDanger,
                      fond: HydroticColors.riskRouge,
                      texte: blanc,
                      onTap: () => context.go('/sos'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: HydroticSpacing.gapM),
        Container(
          padding: const EdgeInsets.all(HydroticSpacing.gapL),
          decoration: BoxDecoration(
            color: blanc.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(HydroticRadius.chip),
          ),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: Fr.nomApp, style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: ' · ${Fr.ilYAHeures(heures)}\n${precedente.corps}'),
            ]),
            style: HydroticText.caption.copyWith(color: HydroticColors.gray),
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.fond, required this.texte, required this.onTap});

  final String label;
  final Color fond;
  final Color texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(HydroticRadius.legend));
    return Material(
      color: fond,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HydroticSizes.touchTarget),
          child: Center(
            child: Text(label, style: HydroticText.caption.copyWith(color: texte, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
