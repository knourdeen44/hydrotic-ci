import 'package:flutter/foundation.dart';

import '../data/api/navigateur.dart';
import '../data/mode.dart';

/// Connexion Clerk (mode réel) : lue au démarrage, mise à jour à la connexion et à la déconnexion.
final session = ValueNotifier<bool>(false);

Future<void> initialiserSession() async {
  if (modeApi) session.value = await Navigateur.connecte();
}
