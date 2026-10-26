import 'dart:convert';

import 'package:flutter/services.dart';

/// Lit les fichiers `assets/fixtures/*.json` (une seule lecture par fichier).
class FixtureLoader {
  FixtureLoader([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final _cache = <String, Future<Map<String, dynamic>>>{};

  Future<Map<String, dynamic>> load(String name) => _cache.putIfAbsent(name, () async {
        final text = await _bundle.loadString('assets/fixtures/$name.json');
        return jsonDecode(text) as Map<String, dynamic>;
      });
}
