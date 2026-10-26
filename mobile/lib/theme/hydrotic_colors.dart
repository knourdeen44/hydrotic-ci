// GÉNÉRÉ par tools/gen_tokens.mjs depuis design/tokens.json — ne pas modifier à la main.

import 'package:flutter/painting.dart';

/// Couleurs Hydrotic CI.
abstract final class HydroticColors {
  // brand
  /// Couleur principale : boutons, élément actif, barres de pluie, puces
  static const Color slate = Color(0xFF6C809A);
  /// Texte sur fond slateLight, onglet actif
  static const Color slateDark = Color(0xFF55667D);
  /// Bordures, chips, boutons secondaires, poignée de feuille
  static const Color slateLight = Color(0xFFE1E6EC);
  /// Fond des cartes, fond du tableau de bord
  static const Color slateXLight = Color(0xFFF3F5F8);
  /// Texte principal, barre latérale du tableau de bord
  static const Color gray = Color(0xFF464A4F);
  /// Texte secondaire, libellés
  static const Color grayLight = Color(0xFF8A9097);
  /// Accent ponctuel : position « Vous », liens, tâche critique
  static const Color deep = Color(0xFF1B3A60);
  /// Cadre du téléphone dans les captures uniquement (pas dans l'app)
  static const Color phoneFrame = Color(0xFF2B2E31);
  /// Fond de carte schématique
  static const Color mapBackground = Color(0xFFEEF1F4);
  /// Plan d'eau sur la carte schématique
  static const Color mapWater = Color(0xFFDCE4EC);
  static const Color white = Color(0xFFFFFFFF);

  // risk
  static const Color riskVert = Color(0xFF3F8F5B);
  static const Color riskJaune = Color(0xFFD9A520);
  static const Color riskOrange = Color(0xFFD9731E);
  static const Color riskRouge = Color(0xFFC0392B);

  // status
  static const Color statusRecuBg = Color(0x1FC0392B);
  static const Color statusRecuFg = Color(0xFFC0392B);
  static const Color statusEnRouteBg = Color(0x2ED9A520);
  static const Color statusEnRouteFg = Color(0xFF8A6A12);
  static const Color statusSecouruBg = Color(0xFFE1E6EC);
  static const Color statusSecouruFg = Color(0xFF55667D);

  // overlay
  static const Color overlayZoneOrangeFill = Color(0x38D9731E);
  static const Color overlayZoneOrangeStroke = Color(0xFFD9731E);
  static const Color overlayZoneRougeFill = Color(0x38C0392B);
  static const Color overlayZoneRougeStroke = Color(0xFFC0392B);
}

/// Ombres Hydrotic CI.
abstract final class HydroticShadows {
  static const List<BoxShadow> sos = [BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 16.0, color: Color(0x59C0392B))];
  static const List<BoxShadow> banner = [BoxShadow(offset: Offset(0.0, 10.0), blurRadius: 30.0, color: Color(0x2E000000))];
  static const List<BoxShadow> sheet = [BoxShadow(offset: Offset(0.0, -6.0), blurRadius: 20.0, color: Color(0x1A000000))];
  static const List<BoxShadow> legend = [BoxShadow(offset: Offset(0.0, 2.0), blurRadius: 8.0, color: Color(0x0F000000))];
}
