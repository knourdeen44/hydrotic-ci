import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/niveau_risque.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../widgets/consignes_sheet.dart';
import 'citizen_scaffold.dart';

/// Calques de la feuille « Que faire avant demain ? » au-dessus de la barre de navigation :
/// zone transparente (un appui ferme la feuille) puis la feuille.
List<Widget> consignesOverlay({
  required NiveauRisque niveau,
  required String zone,
  required VoidCallback onClose,
}) =>
    [
      Positioned.fill(
        bottom: CitizenScaffold.sheetBottom,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onClose),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: CitizenScaffold.sheetBottom,
        child: _Consignes(niveau: niveau, zone: zone),
      ),
    ];

class _Consignes extends ConsumerWidget {
  const _Consignes({required this.niveau, required this.zone});

  final NiveauRisque niveau;
  final String zone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consignes = ref.watch(consignesProvider(niveau)).valueOrNull;
    if (consignes == null) return const SizedBox.shrink();
    return ConsignesSheet(
      titre: Fr.queFaireAvantDemain,
      sousTitre: Fr.consignesPour(niveau.name, zone),
      consignes: consignes,
      niveau: niveau,
    );
  }
}
