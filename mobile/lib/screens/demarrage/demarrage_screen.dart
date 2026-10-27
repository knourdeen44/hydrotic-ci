import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api/navigateur.dart';
import '../../data/mode.dart';
import '../../data/providers.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../state/session.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/check_card.dart';
import '../../widgets/hydrotic_button.dart';
import '../../widgets/hydrotic_text_field.dart';
import '../../widgets/sos_fab.dart';
import '../../widgets/long_press_1s.dart';
import '../demo/demo_menu.dart';
import 'demarrage_etape.dart';

/// Étapes du démarrage (M0).
enum EtapeDemarrage { bienvenue, connexion, quartiers, autorisations }

/// M0 — Démarrage : bienvenue, connexion / inscription (sans vérification), quartiers, autorisations.
/// Ouvert depuis le profil (« Modifier ») sur l'étape des quartiers, il y revient ensuite.
class DemarrageScreen extends ConsumerStatefulWidget {
  const DemarrageScreen({super.key, this.etape = EtapeDemarrage.bienvenue, this.depuisProfil = false});

  final EtapeDemarrage etape;
  final bool depuisProfil;

  @override
  ConsumerState<DemarrageScreen> createState() => _DemarrageScreenState();
}

class _DemarrageScreenState extends ConsumerState<DemarrageScreen> {
  late EtapeDemarrage _etape = widget.etape;
  bool _inscription = true;
  List<String>? _quartiers;
  bool _notifications = true;
  bool _localisation = true;

  void _aller(EtapeDemarrage etape) => setState(() => _etape = etape);

  void _validerQuartiers(List<String> quartiers) {
    ref.read(choixZonesProvider.notifier).state = quartiers;
    if (modeApi) ref.read(userRepositoryProvider).enregistrer(zonesSuivies: quartiers).ignore();
    if (widget.depuisProfil) {
      _retourProfil();
    } else {
      _aller(EtapeDemarrage.autorisations);
    }
  }

  /// Mode réel : fenêtre de connexion Clerk ; mode démo : formulaire sans vérification.
  Future<void> _connexion({required bool inscription}) async {
    if (!modeApi) {
      setState(() {
        _inscription = inscription;
        _etape = EtapeDemarrage.connexion;
      });
      return;
    }
    final connecte = await Navigateur.connecter(inscription: inscription);
    if (!mounted || !connecte) return;
    session.value = true;
    ref.invalidate(citoyenProvider);
    _aller(EtapeDemarrage.quartiers);
  }

  void _retourProfil() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HydroticColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _contenu()),
            // Bouton SOS présent sur tous les écrans de l'application citoyenne.
            Positioned(
              right: SosFab.right,
              bottom: SosFab.gapAboveNav,
              child: SosFab(onPressed: () => context.push('/sos')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenu() {
    switch (_etape) {
      case EtapeDemarrage.bienvenue:
        return _bienvenue();
      case EtapeDemarrage.connexion:
        return DemarrageEtape(
          titre: _inscription ? Fr.inscription : Fr.connexion,
          onBack: () => _aller(EtapeDemarrage.bienvenue),
          bouton: HydroticButton(label: Fr.continuer, onPressed: () => _aller(EtapeDemarrage.quartiers)),
          children: const [
            HydroticTextField(label: Fr.champEmail, keyboardType: TextInputType.emailAddress),
            SizedBox(height: HydroticSpacing.gapM),
            HydroticTextField(label: Fr.champMotDePasse, obscureText: true),
          ],
        );
      case EtapeDemarrage.quartiers:
        return _etapeQuartiers();
      case EtapeDemarrage.autorisations:
        return DemarrageEtape(
          titre: Fr.autorisations,
          onBack: () => _aller(EtapeDemarrage.quartiers),
          bouton: HydroticButton(
            label: Fr.commencer,
            onPressed: () {
              // Mode réel : demande d'autorisation de localisation du navigateur.
              if (modeApi && _localisation) ref.read(positionGpsProvider.future).ignore();
              context.go('/');
            },
          ),
          children: [
            CarteAutorisation(
              icon: Icons.notifications_rounded,
              titre: Fr.notifications,
              texte: Fr.autorisationNotifications,
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            const SizedBox(height: HydroticSpacing.gapM),
            CarteAutorisation(
              icon: Icons.location_on_rounded,
              titre: Fr.localisation,
              texte: Fr.autorisationLocalisation,
              value: _localisation,
              onChanged: (v) => setState(() => _localisation = v),
            ),
          ],
        );
    }
  }

  Widget _bienvenue() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, HydroticSizes.sosFab + 32),
      child: Column(
        children: [
          LongPress1s(
            onLongPress: () => showDemoMenu(context),
            child: Image.asset('assets/images/logo_hydrotic_full.png', width: 160, semanticLabel: Fr.nomApp),
          ),
          const SizedBox(height: HydroticSpacing.dashGap),
          Text(Fr.nomApp, style: HydroticText.riskTitle.copyWith(color: HydroticColors.gray)),
          const SizedBox(height: 6),
          Text(
            Fr.slogan,
            textAlign: TextAlign.center,
            style: HydroticText.body.copyWith(color: HydroticColors.grayLight),
          ),
          const SizedBox(height: 32),
          HydroticButton(
            label: Fr.creerCompte,
            onPressed: () => _connexion(inscription: true),
          ),
          const SizedBox(height: HydroticSpacing.gapM),
          HydroticButton(
            label: Fr.dejaUnCompte,
            secondary: true,
            onPressed: () => _connexion(inscription: false),
          ),
        ],
      ),
    );
  }

  Widget _etapeQuartiers() {
    final zones = ref.watch(zonesProvider).valueOrNull ?? const [];
    final suivies = ref.watch(zonesSuiviesProvider).valueOrNull ?? const <String>[];
    final choix = _quartiers ?? suivies;
    return DemarrageEtape(
      titre: Fr.quelsQuartiers,
      onBack: widget.depuisProfil
          ? _retourProfil
          : () => _aller(modeApi ? EtapeDemarrage.bienvenue : EtapeDemarrage.connexion),
      bouton: HydroticButton(
        label: Fr.continuer,
        onPressed: choix.isEmpty ? null : () => _validerQuartiers(choix),
      ),
      children: [
        for (final zone in zones) ...[
          CheckCard(
            titre: zone.nom == zone.commune ? zone.nom : '${zone.nom} — ${zone.commune}',
            sousTitre: zone.profil,
            checked: choix.contains(zone.id),
            onChanged: (coche) => setState(() {
              // Ordre des fixtures conservé.
              _quartiers = [
                for (final z in zones)
                  if (z.id == zone.id ? coche : choix.contains(z.id)) z.id,
              ];
            }),
          ),
          const SizedBox(height: HydroticSpacing.gapM),
        ],
      ],
    );
  }
}
