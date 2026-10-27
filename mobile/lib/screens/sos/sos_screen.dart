import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api/navigateur.dart';
import '../../data/mode.dart';
import '../../data/models/sos.dart';
import '../../data/providers.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../state/session.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/dashed_button.dart';
import '../../widgets/sos_hold_button.dart';
import '../../widgets/toast.dart';
import '../shell/citizen_scaffold.dart';
import 'sos_options.dart';
import 'sos_sent_view.dart';

/// M4 — SOS : repos → maintien (3 s) → envoyé. Pas de bouton SOS flottant ici.
/// Avec [scenario], rejoue la vidéo v3_sos (maintien simulé).
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key, this.scenario = false});

  final bool scenario;

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  // Délais du prototype s3_sos.
  static const _debutMaintienScenario = Duration(milliseconds: 1300);
  static const _delaiEnvoi = Duration(milliseconds: 300);
  static const _delaiEquipe = Duration(milliseconds: 2400);
  static const _delaiInfo = Duration(milliseconds: 2700);

  final _bouton = GlobalKey<SosHoldButtonState>();
  final _timers = <Timer>[];
  bool _envoye = false;
  bool _equipeEnRoute = false;
  bool _info = false;
  SosOptionsValeurs? _options;

  /// Mode réel : suivi du SOS envoyé, rafraîchi toutes les 15 s.
  SosCourant? _suivi;
  Timer? _sondage;

  @override
  void initState() {
    super.initState();
    if (widget.scenario) {
      _plusTard(_debutMaintienScenario, () => _bouton.currentState?.demarrerMaintien());
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _sondage?.cancel();
    super.dispose();
  }

  void _plusTard(Duration delai, VoidCallback action) => _timers.add(Timer(delai, () {
        if (mounted) action();
      }));

  void _maintienTermine() {
    if (modeApi) {
      unawaited(_envoyerReel());
      return;
    }
    _plusTard(_delaiEnvoi, () => setState(() => _envoye = true));
    _plusTard(_delaiEnvoi + _delaiEquipe, () => setState(() => _equipeEnRoute = true));
    _plusTard(_delaiEnvoi + _delaiInfo, () => setState(() => _info = true));
  }

  /// Mode réel : connexion si besoin, envoi avec la position GPS, puis suivi.
  Future<void> _envoyerReel() async {
    final repo = ref.read(sosRepositoryProvider);
    final brouillon = ref.read(sosCourantProvider).valueOrNull;
    if (!session.value) session.value = await Navigateur.connecter(inscription: false);
    if (!session.value) {
      if (mounted) showToast(context, Fr.connexionRequise);
      return;
    }
    final options = _options ?? (brouillon == null ? null : SosOptionsValeurs.depuis(brouillon));
    final gps = await ref.read(positionGpsProvider.future);
    try {
      final suivi = await repo.envoyer((
        personnes: options?.personnes ?? 1,
        blesses: options?.blesses ?? false,
        hauteurEau: options?.hauteurEau ?? Fr.hauteurs.first,
        enfantsOuAges: options?.enfantsOuAges ?? false,
        geo: gps?.geo,
        precisionM: gps?.precisionM,
      ));
      if (!mounted) return;
      setState(() {
        _suivi = suivi;
        _envoye = true;
        _info = true;
      });
      _sondage = Timer.periodic(const Duration(seconds: 15), (_) async {
        try {
          final maj = await repo.suivre(suivi.id!);
          if (mounted) setState(() => _suivi = maj);
        } on Exception {
          // Réseau indisponible : nouvel essai au passage suivant.
        }
      });
    } on Exception catch (e) {
      if (mounted) showToast(context, '$e');
    }
  }

  void _retour() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sos = ref.watch(sosCourantProvider).valueOrNull;
    return CitizenScaffold(
      showSosFab: false,
      body: sos == null
          ? const SizedBox.shrink()
          : Stack(
              fit: StackFit.expand,
              children: [
                _repos(sos),
                IgnorePointer(
                  ignoring: !_envoye,
                  child: AnimatedOpacity(
                    opacity: _envoye ? 1 : 0,
                    duration: const Duration(milliseconds: 450),
                    child: _envoye
                        ? SosSentView(
                            etapes: _suivi?.timeline ??
                                [
                              // L'étape « Équipe en route » se coche 2,4 s après l'envoi (simulation).
                              for (final (i, e) in sos.timeline.indexed)
                                EtapeSos(etape: e.etape, detail: e.detail, fait: i == 0 || (_equipeEnRoute && e.fait)),
                            ],
                            afficherInfo: _info,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 0,
                  child: IconButton(
                    onPressed: _retour,
                    tooltip: Fr.retour,
                    icon: const Icon(Icons.arrow_back_rounded, color: HydroticColors.gray),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _repos(SosCourant sos) {
    final options = _options ?? SosOptionsValeurs.depuis(sos);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(HydroticSpacing.headerPaddingX, 8, HydroticSpacing.headerPaddingX, 16),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(Fr.besoinAide, style: HydroticText.screenTitle.copyWith(color: HydroticColors.gray)),
          const SizedBox(height: 4),
          Text(
            Fr.maintenezBouton,
            textAlign: TextAlign.center,
            style: HydroticText.caption.copyWith(color: HydroticColors.grayLight),
          ),
          const SizedBox(height: 20),
          SosHoldButton(key: _bouton, onComplete: _maintienTermine),
          const SizedBox(height: 14),
          _Position(lieu: sos.lieu, precisionM: sos.precisionM),
          const SizedBox(height: HydroticSpacing.gapM),
          SosOptions(valeurs: options, onChanged: (v) => setState(() => _options = v)),
          const SizedBox(height: HydroticSpacing.gapL),
          DashedButton(label: Fr.envoyerParSms, onTap: () => showToast(context, Fr.bientot)),
        ],
      ),
    );
  }
}

/// Carte de position (prototype : `.pos`). Valeur fictive, pas de géolocalisation en phase 1.
class _Position extends StatelessWidget {
  const _Position({required this.lieu, required this.precisionM});

  final String lieu;
  final double precisionM;

  @override
  Widget build(BuildContext context) {
    final style = HydroticText.small.copyWith(color: HydroticColors.gray);
    return Container(
      padding: const EdgeInsets.all(HydroticSpacing.gapM),
      decoration: BoxDecoration(
        color: HydroticColors.slateXLight,
        borderRadius: BorderRadius.circular(HydroticRadius.legend),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(color: HydroticColors.deep, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fr.positionTrouvee, style: style.copyWith(fontWeight: FontWeight.w700)),
                Text(Fr.precision(precisionM, lieu), style: style),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
