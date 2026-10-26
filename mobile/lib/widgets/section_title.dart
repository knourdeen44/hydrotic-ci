import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Titre de section 13/700 (prototype : `.h`, marges 12 / 8).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: HydroticSpacing.gapL, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(texte, style: HydroticText.sectionTitle.copyWith(color: HydroticColors.gray)),
      ),
    );
  }
}
