import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Accès rapide : Carte, Signaler, Consignes (prototype : `.acts`).
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, this.onCarte, this.onSignaler, this.onConsignes});

  final VoidCallback? onCarte;
  final VoidCallback? onSignaler;
  final VoidCallback? onConsignes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Action(icon: Icons.map_rounded, label: Fr.actionCarte, onTap: onCarte)),
        const SizedBox(width: 8),
        Expanded(
          child: _Action(icon: Icons.add_location_alt_rounded, label: Fr.actionSignaler, onTap: onSignaler),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Action(icon: Icons.checklist_rounded, label: Fr.actionConsignes, onTap: onConsignes),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      side: const BorderSide(color: HydroticColors.slateLight),
      borderRadius: BorderRadius.circular(HydroticRadius.action),
    );
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: HydroticColors.white,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            // 10 / 6 px du prototype + 1 px de bordure (comptée dans la hauteur en CSS).
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 7),
            child: Column(
              children: [
                // L'icône remplace le carré gris de 26 px du prototype.
                Icon(icon, size: 26, color: HydroticColors.slate),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: HydroticText.small.copyWith(
                    color: HydroticColors.gray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
