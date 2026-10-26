import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Bouton pleine largeur : principal (slate plein) ou secondaire (slateLight),
/// comme « Oui » / « Non » du prototype (`.yes` / `.no`). Désactivé si [onPressed] est nul.
class HydroticButton extends StatelessWidget {
  const HydroticButton({super.key, required this.label, required this.onPressed, this.secondary = false});

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final fond = secondary ? HydroticColors.slateLight : HydroticColors.slate;
    final texte = secondary ? HydroticColors.slateDark : HydroticColors.white;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(HydroticRadius.button));
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null ? .5 : 1,
        child: Material(
          color: fond,
          shape: shape,
          child: InkWell(
            onTap: onPressed,
            customBorder: shape,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: HydroticSizes.touchTarget, minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                child: Center(child: Text(label, style: HydroticText.button.copyWith(color: texte))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
