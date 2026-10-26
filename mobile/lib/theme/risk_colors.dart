import 'package:flutter/painting.dart';

import '../data/models/niveau_risque.dart';
import 'hydrotic_colors.dart';

/// Couleurs associées à un niveau de risque (toujours affichées avec un mot).
extension NiveauRisqueCouleurs on NiveauRisque {
  Color get couleur => switch (this) {
        NiveauRisque.vert => HydroticColors.riskVert,
        NiveauRisque.jaune => HydroticColors.riskJaune,
        NiveauRisque.orange => HydroticColors.riskOrange,
        NiveauRisque.rouge => HydroticColors.riskRouge,
      };

  /// Remplissage d'une zone sur la carte schématique.
  Color get remplissageZone => switch (this) {
        NiveauRisque.orange => HydroticColors.overlayZoneOrangeFill,
        NiveauRisque.rouge => HydroticColors.overlayZoneRougeFill,
        _ => couleur.withValues(alpha: .22),
      };
}
