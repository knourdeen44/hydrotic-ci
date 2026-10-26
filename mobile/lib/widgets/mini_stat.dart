import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Mini-carte de statistique (prototype : `.mini`). À placer dans un [Expanded].
class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.label, required this.value, this.dotColor});

  final String label;
  final String value;

  /// Pastille de couleur avant la valeur (niveau de risque).
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HydroticSpacing.gapL),
      decoration: BoxDecoration(
        color: HydroticColors.slateXLight,
        borderRadius: BorderRadius.circular(HydroticRadius.mini),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: HydroticText.small.copyWith(color: HydroticColors.grayLight)),
          const SizedBox(height: 3),
          Row(
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HydroticText.statValue.copyWith(color: HydroticColors.gray),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
