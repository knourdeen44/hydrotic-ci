// GÉNÉRÉ par tools/gen_tokens.mjs depuis design/tokens.json — ne pas modifier à la main.

import 'package:flutter/painting.dart';

/// Styles de texte Hydrotic CI (application mobile).
abstract final class HydroticText {
  static const String fontFamily = 'Inter';

  /// Hauteur de ligne « normale » (navigateur) d'un texte de [taille] px, en multiple de la taille.
  static double hauteurNormale(double taille) => ((taille * 0.96875).round() + (taille * 0.2412109375).round()) / taille;

  static const TextStyle riskTitle = TextStyle(fontFamily: fontFamily, fontSize: 26.0, fontWeight: FontWeight.w800, height: 1.1923);
  static const TextStyle screenTitle = TextStyle(fontFamily: fontFamily, fontSize: 20.0, fontWeight: FontWeight.w800, height: 1.2);
  static const TextStyle sheetTitle = TextStyle(fontFamily: fontFamily, fontSize: 17.0, fontWeight: FontWeight.w800, height: 1.3);
  static const TextStyle greeting = TextStyle(fontFamily: fontFamily, fontSize: 16.0, fontWeight: FontWeight.w700, height: 1.25);
  static const TextStyle statValue = TextStyle(fontFamily: fontFamily, fontSize: 15.0, fontWeight: FontWeight.w700, height: 1.2667);
  static const TextStyle button = TextStyle(fontFamily: fontFamily, fontSize: 14.0, fontWeight: FontWeight.w700, height: 1.2143);
  static const TextStyle sectionTitle = TextStyle(fontFamily: fontFamily, fontSize: 13.0, fontWeight: FontWeight.w700, height: 1.2308);
  static const TextStyle body = TextStyle(fontFamily: fontFamily, fontSize: 13.0, fontWeight: FontWeight.w400, height: 1.4);
  /// À afficher en MAJUSCULES (`toUpperCase()`).
  static const TextStyle overline = TextStyle(fontFamily: fontFamily, fontSize: 12.0, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: 1.0);
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontSize: 12.0, fontWeight: FontWeight.w400, height: 1.25);
  static const TextStyle small = TextStyle(fontFamily: fontFamily, fontSize: 11.0, fontWeight: FontWeight.w400, height: 1.2727);
  static const TextStyle navLabel = TextStyle(fontFamily: fontFamily, fontSize: 10.0, fontWeight: FontWeight.w400, height: 1.2);
  static const TextStyle navLabelActive = TextStyle(fontFamily: fontFamily, fontSize: 10.0, fontWeight: FontWeight.w700, height: 1.2);
}
