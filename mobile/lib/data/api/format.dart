// Dates de l'API (ISO 8601) mises en forme comme dans les fixtures. Abidjan : UTC toute l'année.

const _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
const _mois = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

DateTime _abidjan(String iso) => DateTime.parse(iso).toUtc();

String _deuxChiffres(int n) => n.toString().padLeft(2, '0');

/// « 18:42 ».
String heure(String iso) {
  final d = _abidjan(iso);
  return '${_deuxChiffres(d.hour)}:${_deuxChiffres(d.minute)}';
}

/// « Mercredi 17 juin · 18:42 ».
String dateAlerte(String iso) {
  final d = _abidjan(iso);
  return '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]} · ${heure(iso)}';
}

/// Ancienneté : « 38 min », « 1 h », « 2 j ».
String depuis(String iso, [DateTime? maintenant]) {
  final minutes = (maintenant ?? DateTime.now()).toUtc().difference(_abidjan(iso)).inMinutes;
  if (minutes < 60) return '${minutes < 0 ? 0 : minutes} min';
  if (minutes < 24 * 60) return '${minutes ~/ 60} h';
  return '${minutes ~/ (24 * 60)} j';
}
