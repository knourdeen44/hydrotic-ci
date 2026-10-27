/// Coordonnée géographique (WGS 84).
typedef Geo = ({double lat, double lon});

/// Lit `{lat, lon}` (API) ; nul si absent.
Geo? geoDepuisJson(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  return (lat: (json['lat'] as num).toDouble(), lon: (json['lon'] as num).toDouble());
}
