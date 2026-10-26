import 'dart:ui';

/// Convertit un chemin SVG simple (commandes absolues M, L, C, S, Z) en [Path] Flutter.
/// Suffit pour les contours schématiques des fixtures ; pas de dépendance externe.
Path parseSvgPath(String data) {
  final tokens = RegExp(r'[MLCSZ]|-?\d*\.?\d+', caseSensitive: false)
      .allMatches(data)
      .map((m) => m.group(0)!)
      .toList();
  final path = Path();
  var i = 0;
  var command = 'M';
  // Dernier point de contrôle (pour la commande S).
  Offset? lastControl;
  var current = Offset.zero;

  double next() => double.parse(tokens[i++]);
  Offset point() => Offset(next(), next());

  while (i < tokens.length) {
    if (RegExp('[A-Za-z]').hasMatch(tokens[i])) command = tokens[i++].toUpperCase();
    switch (command) {
      case 'M':
        current = point();
        path.moveTo(current.dx, current.dy);
        lastControl = null;
        command = 'L'; // Coordonnées suivantes implicites = lignes.
      case 'L':
        current = point();
        path.lineTo(current.dx, current.dy);
        lastControl = null;
      case 'C':
        final c1 = point(), c2 = point(), end = point();
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastControl = c2;
        current = end;
      case 'S':
        final c1 = lastControl == null ? current : current * 2 - lastControl;
        final c2 = point(), end = point();
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastControl = c2;
        current = end;
      case 'Z':
        path.close();
        lastControl = null;
      default:
        throw FormatException('Commande SVG non prise en charge : $command');
    }
  }
  return path;
}
