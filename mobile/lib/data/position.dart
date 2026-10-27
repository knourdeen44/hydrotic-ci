import 'package:geolocator/geolocator.dart';

import 'models/geo.dart';

/// Position de l'appareil et précision en mètres.
typedef PositionGps = ({Geo geo, double precisionM});

/// Position réelle (mode réel) ; nulle si la localisation est refusée, indisponible ou trop lente.
/// Ne bloque jamais l'affichage plus de 10 s (Safari peut ne jamais répondre).
Future<PositionGps?> lirePositionGps() =>
    _lire().timeout(const Duration(seconds: 10), onTimeout: () => null);

Future<PositionGps?> _lire() async {
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 8)),
    );
    return (geo: (lat: p.latitude, lon: p.longitude), precisionM: p.accuracy);
  } catch (_) {
    // Erreurs du navigateur (permission, API absente) : sans position.
    return null;
  }
}
