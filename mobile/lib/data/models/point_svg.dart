/// Point dans le repère SVG d'une carte schématique (pas une coordonnée géographique).
class PointSvg {
  const PointSvg(this.x, this.y);

  factory PointSvg.fromJson(Map<String, dynamic> json) =>
      PointSvg((json['x'] as num).toDouble(), (json['y'] as num).toDouble());

  final double x;
  final double y;
}
