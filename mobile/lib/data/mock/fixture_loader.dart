import 'dart:convert';

import 'package:flutter/services.dart';

import '../../l10n/fr.dart';

/// Lit les fichiers `assets/fixtures/*.json` (une seule lecture par fichier).
class FixtureLoader {
  FixtureLoader([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final _cache = <String, Future<Map<String, dynamic>>>{};

  Future<Map<String, dynamic>> load(String name) => _cache.putIfAbsent(name, () async {
        final text = await _bundle.loadString('assets/fixtures/$name.json');
        return jsonDecode(typographieFr(text)) as Map<String, dynamic>;
      });
}

/// Typographie française : espace insécable avant « : ? ! % » et à l'intérieur des guillemets.
/// Une espace ordinaire avant ces signes n'apparaît que dans les textes (jamais dans la syntaxe JSON).
String typographieFr(String text) => text
    .replaceAllMapped(RegExp(r' ([:?!%»])'), (m) => '$nbsp${m[1]}')
    .replaceAll('« ', '«$nbsp');
