import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';

/// Indicateur de chargement (mode réel : réseau, connexion, GPS).
class Chargement extends StatelessWidget {
  const Chargement({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3, color: HydroticColors.slate),
        ),
      );
}
