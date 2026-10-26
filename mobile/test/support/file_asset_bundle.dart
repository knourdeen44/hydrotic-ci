import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hydrotic_ci/data/mock/fixture_loader.dart';

/// Lit les assets directement sur le disque, de façon synchrone (compatible avec le temps simulé
/// des tests de widgets). Les tests sont lancés depuis la racine du paquet `mobile/`.
class FileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    final bytes = File(key).readAsBytesSync();
    return SynchronousFuture(ByteData.sublistView(bytes));
  }
}

FixtureLoader testFixtureLoader() => FixtureLoader(FileAssetBundle());
