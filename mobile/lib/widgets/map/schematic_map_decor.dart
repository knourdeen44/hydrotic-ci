// Fond de la carte schématique (prototype : SVG de `.map`, viewBox 0 0 340 700).
// Purement décoratif : remplacé par une vraie carte (flutter_map + OpenStreetMap) en phase 2.

/// Taille du repère SVG de la carte mobile.
const double mapViewBoxWidth = 340;
const double mapViewBoxHeight = 700;

/// Plan d'eau.
const String mapWaterPath = 'M0 120 C80 140 120 90 200 130 S320 160 340 140 L340 0 L0 0Z';

/// Routes : (chemin SVG, épaisseur).
const List<(String, double)> mapRoads = [
  ('M-10 260 L360 300', 14),
  ('M120 0 L170 700', 12),
  ('M-10 440 L360 400', 10),
  ('M260 120 L230 700', 8),
];
