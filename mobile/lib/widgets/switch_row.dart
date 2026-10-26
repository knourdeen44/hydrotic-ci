import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Ligne avec interrupteur (état local). [onChanged] nul : ligne non désactivable.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.titre,
    required this.value,
    required this.onChanged,
    this.description,
    this.icon,
  });

  final String titre;
  final String? description;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final icon = this.icon;
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: HydroticSizes.touchTarget),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: HydroticColors.slate),
              const SizedBox(width: HydroticSpacing.gapL),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: HydroticText.sectionTitle.copyWith(color: HydroticColors.gray)),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(description, style: HydroticText.caption.copyWith(color: HydroticColors.grayLight)),
                  ],
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
