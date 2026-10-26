import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/point_svg.dart';
import '../../data/models/signalement.dart';
import '../../data/providers.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../widgets/choice_chips.dart';
import '../../widgets/dashed_button.dart';
import '../../widgets/hydrotic_button.dart';
import '../../widgets/hydrotic_text_field.dart';
import '../../widgets/map/schematic_map_decor.dart';
import '../../widgets/schematic_map.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/section_title.dart';
import '../../widgets/toast.dart';
import '../carte/carte_data.dart';
import '../shell/citizen_scaffold.dart';

/// M7 — Signaler une inondation. Le signalement est ajouté localement (statut « À confirmer »).
class SignalerScreen extends ConsumerStatefulWidget {
  const SignalerScreen({super.key});

  @override
  ConsumerState<SignalerScreen> createState() => _SignalerScreenState();
}

class _SignalerScreenState extends ConsumerState<SignalerScreen> {
  static const _hauteurCarte = 200.0;

  final _commentaire = TextEditingController();
  String? _hauteur;
  bool _envoi = false;

  @override
  void dispose() {
    _commentaire.dispose();
    super.dispose();
  }

  void _retour() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _envoyer() async {
    setState(() => _envoi = true);
    final reports = ref.read(reportRepositoryProvider);
    final citoyen = await ref.read(citoyenProvider.future);
    final vous = await ref.read(positionVousProvider.future);
    await reports.ajouter(Signalement(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      zoneId: citoyen.zonesSuivies.first,
      rue: Fr.legendeSignalement,
      statut: StatutSignalement.aConfirmer,
      oui: 0,
      non: 0,
      il: '',
      // Juste à côté de la position « Vous » (pas de géolocalisation en phase 1).
      position: PointSvg(vous.x + 20, vous.y - 20),
      hauteurEau: _hauteur,
    ));
    if (!mounted) return;
    ref.invalidate(signalementsProvider);
    showToast(context, Fr.merciVoisins);
    context.go('/carte');
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(carteProvider).valueOrNull;
    return CitizenScaffold(
      body: Column(
        children: [
          ScreenHeader(titre: Fr.signalerInondation, onBack: _retour),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                HydroticSpacing.screenPadding,
                0,
                HydroticSpacing.screenPadding,
                HydroticSpacing.screenPadding + HydroticSizes.sosFab,
              ),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(HydroticRadius.mini),
                  child: SizedBox(
                    height: _hauteurCarte,
                    child: d == null
                        ? const SizedBox.shrink()
                        : LayoutBuilder(
                            builder: (context, c) => SchematicMap(
                              showLegend: false,
                              animateActif: false,
                              alignment: _centrage(c.maxWidth, d.positionVous),
                              zones: [
                                for (final z in d.zones) (zone: z, niveau: d.niveauxAujourdhui[z.id]!),
                              ],
                              signalements: d.signalements,
                              positionVous: d.positionVous,
                            ),
                          ),
                  ),
                ),
                const SectionTitle(Fr.hauteurEau),
                ChoiceChips(
                  options: Fr.hauteurs,
                  selected: _hauteur,
                  onSelected: (h) => setState(() => _hauteur = h),
                ),
                const SectionTitle(Fr.photoFacultatif),
                DashedButton(label: Fr.ajouterPhoto, onTap: () => showToast(context, Fr.bientot)),
                const SectionTitle(Fr.commentaire),
                HydroticTextField(label: Fr.commentaire, controller: _commentaire, maxLines: 3),
                const SizedBox(height: HydroticSpacing.dashGap),
                HydroticButton(
                  label: Fr.envoyerSignalement,
                  // La hauteur d'eau est obligatoire.
                  onPressed: _hauteur == null || _envoi ? null : _envoyer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Alignement qui centre verticalement la mini-carte sur la position « Vous ».
  static Alignment _centrage(double largeur, PointSvg vous) {
    final echelle = math.max(largeur / mapViewBoxWidth, _hauteurCarte / mapViewBoxHeight);
    final hauteur = mapViewBoxHeight * echelle;
    if (hauteur <= _hauteurCarte) return Alignment.center;
    final haut = (vous.y * echelle - _hauteurCarte / 2).clamp(0.0, hauteur - _hauteurCarte);
    return Alignment(0, 2 * haut / (hauteur - _hauteurCarte) - 1);
  }
}
