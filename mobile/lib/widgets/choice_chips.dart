import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Puces à choix unique (rayon 20, zone tactile 44 px) : choisie = slate plein.
class ChoiceChips extends StatelessWidget {
  const ChoiceChips({super.key, required this.options, required this.selected, required this.onSelected});

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options) _Chip(label: option, actif: option == selected, onTap: () => onSelected(option)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.actif, required this.onTap});

  final String label;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(HydroticRadius.chip));
    return Semantics(
      button: true,
      selected: actif,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: actif ? HydroticColors.slate : HydroticColors.slateLight,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Container(
            height: HydroticSizes.touchTarget,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            child: Text(
              label,
              style: HydroticText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: actif ? HydroticColors.white : HydroticColors.slateDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
