import 'package:geolocator/geolocator.dart';

import 'models/geo.dart';

/// Position de l'appareil et précision en mètres.
typedef PositionGps = ({Geo geo, double precisionM});

/// Position réelle (mode réel) ; nulle si la localisation est refusée ou indisponible.
Future<PositionGps?> lirePositionGps() async {
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 15)),
    );
    return (geo: (lat: p.latitude, lon: p.longitude), precisionM: p.accuracy);
  } on Exception {
    return null;
  }
}
