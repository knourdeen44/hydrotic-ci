import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/utilisateur.dart';
import '../../data/models/zone.dart';
import '../../l10n/fr.dart';
import '../../state/app_state.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/hydrotic_button.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/section_title.dart';
import '../../widgets/switch_row.dart';
import '../../widgets/toast.dart';
import '../shell/citizen_scaffold.dart';

final _profilProvider = FutureProvider<({Utilisateur citoyen, List<Zone> zones, List<String> suivies})>(
  (ref) async {
    final citoyenF = ref.watch(citoyenProvider.future);
    final zonesF = ref.watch(zonesProvider.future);
    final suiviesF = ref.watch(zonesSuiviesProvider.future);
    return (citoyen: await citoyenF, zones: await zonesF, suivies: await suiviesF);
  },
);

/// M6 — Profil : identité, quartiers, canaux d'alerte, fiabilité, numéros, données personnelles.
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(_profilProvider).valueOrNull;
    return CitizenScaffold(
      tab: HydroticTab.profil,
      body: Column(
        children: [
          const ScreenHeader(titre: Fr.navProfil),
          Expanded(child: d == null ? const SizedBox.shrink() : _contenu(context, ref, d)),
        ],
      ),
    );
  }

  Widget _contenu(
    BuildContext context,
    WidgetRef ref,
    ({Utilisateur citoyen, List<Zone> zones, List<String> suivies}) d,
  ) {
    String nom(String id) => d.zones.firstWhere((z) => z.id == id).nom;
    final canaux = ref.watch(canauxProvider) ?? d.citoyen.canauxPreferes;
    void basculer(Canal canal, bool actif) => ref.read(canauxProvider.notifier).state =
        actif ? {...canaux, canal} : canaux.difference({canal});
    final principale = d.citoyen.zonesSuivies.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HydroticSpacing.screenPadding,
        0,
        HydroticSpacing.screenPadding,
        HydroticSpacing.screenPadding + HydroticSizes.sosFab,
      ),
      children: [
        _Identite(prenom: d.citoyen.nom, ligne: Fr.identite(nom(principale))),
        const SectionTitle(Fr.mesQuartiers),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final id in d.suivies) _Puce(nom(id))],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/demarrage?etape=quartiers&retour=profil'),
              style: TextButton.styleFrom(
                foregroundColor: HydroticColors.deep,
                minimumSize: const Size(HydroticSizes.touchTarget, HydroticSizes.touchTarget),
                textStyle: HydroticText.sectionTitle,
              ),
              child: const Text(Fr.modifier),
            ),
          ],
        ),
        const SectionTitle(Fr.canauxAlerte),
        SwitchRow(
          icon: Icons.notifications_rounded,
          titre: Fr.notifications,
          value: canaux.contains(Canal.push),
          onChanged: (v) => basculer(Canal.push, v),
        ),
        SwitchRow(
          icon: Icons.mail_rounded,
          titre: Fr.email,
          value: canaux.contains(Canal.email),
          onChanged: (v) => basculer(Canal.email, v),
        ),
        const SwitchRow(
          icon: Icons.lock_rounded,
          titre: Fr.alertesRougesToujours,
          value: true,
          onChanged: null,
        ),
        const SectionTitle(Fr.maFiabilite),
        _Carte(
          children: [
            Text(
              Fr.decimal(d.citoyen.scoreFiabilite ?? 0),
              style: HydroticText.riskTitle.copyWith(color: HydroticColors.gray),
            ),
            const SizedBox(height: 4),
            Text(Fr.fiabiliteExplication, style: HydroticText.body.copyWith(color: HydroticColors.grayLight)),
          ],
        ),
        const SectionTitle(Fr.numerosUtiles),
        _Carte(
          children: [
            Text(Fr.numerosACompleter, style: HydroticText.body.copyWith(color: HydroticColors.grayLight)),
          ],
        ),
        const SectionTitle(Fr.donneesPersonnelles),
        HydroticButton(
          label: Fr.supprimerCompte,
          secondary: true,
          onPressed: () => showToast(context, Fr.bientot),
        ),
        const SizedBox(height: HydroticSpacing.dashGap),
        const _BandeauDemo(),
      ],
    );
  }
}

class _Identite extends StatelessWidget {
  const _Identite({required this.prenom, required this.ligne});

  final String prenom;
  final String ligne;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: HydroticColors.slateLight, shape: BoxShape.circle),
          child: Text(
            prenom.isEmpty ? '' : prenom[0],
            style: HydroticText.screenTitle.copyWith(color: HydroticColors.slateDark),
          ),
        ),
        const SizedBox(width: HydroticSpacing.gapL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prenom, style: HydroticText.greeting.copyWith(color: HydroticColors.gray)),
              Text(ligne, style: HydroticText.caption.copyWith(color: HydroticColors.grayLight)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Puce extends StatelessWidget {
  const _Puce(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: HydroticColors.slateLight,
        borderRadius: BorderRadius.circular(HydroticRadius.chip),
      ),
      child: Text(
        label,
        style: HydroticText.caption.copyWith(color: HydroticColors.slateDark, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HydroticSpacing.cardPadding),
      decoration: BoxDecoration(
        color: HydroticColors.slateXLight,
        borderRadius: BorderRadius.circular(HydroticRadius.mini),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

/// Mention « données fictives » visible en mode démo.
class _BandeauDemo extends StatelessWidget {
  const _BandeauDemo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: HydroticSpacing.gapM, horizontal: HydroticSpacing.gapL),
      decoration: BoxDecoration(
        border: Border.all(color: HydroticColors.slateLight),
        borderRadius: BorderRadius.circular(HydroticRadius.legend),
      ),
      child: Text(
        Fr.modeDemo,
        textAlign: TextAlign.center,
        style: HydroticText.small.copyWith(color: HydroticColors.grayLight),
      ),
    );
  }
}
