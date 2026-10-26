import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Carte cochable (titre + sous-texte), contour slate quand elle est cochée.
class CheckCard extends StatelessWidget {
  const CheckCard({
    super.key,
    required this.titre,
    required this.sousTitre,
    required this.checked,
    required this.onChanged,
  });

  final String titre;
  final String sousTitre;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      side: BorderSide(color: checked ? HydroticColors.slate : HydroticColors.slateLight, width: checked ? 2 : 1),
      borderRadius: BorderRadius.circular(HydroticRadius.mini),
    );
    return Semantics(
      checked: checked,
      label: '$titre. $sousTitre',
      excludeSemantics: true,
      child: Material(
        color: HydroticColors.white,
        shape: shape,
        child: InkWell(
          onTap: () => onChanged(!checked),
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre, style: HydroticText.statValue.copyWith(color: HydroticColors.gray)),
                      const SizedBox(height: 3),
                      Text(sousTitre, style: HydroticText.caption.copyWith(color: HydroticColors.grayLight)),
                    ],
                  ),
                ),
                const SizedBox(width: HydroticSpacing.gapM),
                Icon(
                  checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 24,
                  color: checked ? HydroticColors.slate : HydroticColors.grayLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
