import 'package:flutter/material.dart';

import '../../data/models/sos.dart';
import '../../l10n/fr.dart';
import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';

/// Valeurs des 4 options du SOS (modifiables localement).
class SosOptionsValeurs {
  const SosOptionsValeurs({
    required this.personnes,
    required this.blesses,
    required this.hauteurEau,
    required this.enfantsOuAges,
  });

  factory SosOptionsValeurs.depuis(SosCourant sos) => SosOptionsValeurs(
        personnes: sos.nbPersonnes,
        blesses: sos.blesses,
        hauteurEau: sos.hauteurEau,
        enfantsOuAges: sos.enfantsOuAges,
      );

  final int personnes;
  final bool blesses;
  final String hauteurEau;
  final bool enfantsOuAges;

  SosOptionsValeurs copyWith({int? personnes, bool? blesses, String? hauteurEau, bool? enfantsOuAges}) =>
      SosOptionsValeurs(
        personnes: personnes ?? this.personnes,
        blesses: blesses ?? this.blesses,
        hauteurEau: hauteurEau ?? this.hauteurEau,
        enfantsOuAges: enfantsOuAges ?? this.enfantsOuAges,
      );
}

/// Grille 2 × 2 des options (prototype : `.opts` `.opt`). Un appui passe à la valeur suivante.
class SosOptions extends StatelessWidget {
  const SosOptions({super.key, required this.valeurs, required this.onChanged});

  final SosOptionsValeurs valeurs;
  final ValueChanged<SosOptionsValeurs> onChanged;

  @override
  Widget build(BuildContext context) {
    final v = valeurs;
    final hauteurs = Fr.hauteurs;
    final hauteurSuivante = hauteurs[(hauteurs.indexOf(v.hauteurEau) + 1) % hauteurs.length];
    return Column(
      children: [
        Row(
          children: [
            _Option(
              label: Fr.personnes,
              valeur: '${v.personnes}',
              onTap: () => onChanged(v.copyWith(personnes: v.personnes % 9 + 1)),
            ),
            const SizedBox(width: 8),
            _Option(
              label: Fr.blesses,
              valeur: Fr.ouiNon(v.blesses),
              onTap: () => onChanged(v.copyWith(blesses: !v.blesses)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Option(
              label: Fr.hauteurEau,
              valeur: v.hauteurEau,
              onTap: () => onChanged(v.copyWith(hauteurEau: hauteurSuivante)),
            ),
            const SizedBox(width: 8),
            _Option(
              label: Fr.enfantsAges,
              valeur: Fr.ouiNon(v.enfantsOuAges),
              onTap: () => onChanged(v.copyWith(enfantsOuAges: !v.enfantsOuAges)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.label, required this.valeur, required this.onTap});

  final String label;
  final String valeur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      side: const BorderSide(color: HydroticColors.slateLight),
      borderRadius: BorderRadius.circular(HydroticRadius.legend),
    );
    return Expanded(
      child: Semantics(
        button: true,
        label: '$label$nbsp: $valeur',
        excludeSemantics: true,
        child: Material(
          color: HydroticColors.white,
          shape: shape,
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: Padding(
              // 9 px du prototype + 1 px de bordure (comptée dans la hauteur en CSS).
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: HydroticText.small.copyWith(color: HydroticColors.gray)),
                  const SizedBox(height: 2),
                  Text(
                    valeur,
                    style: HydroticText.sectionTitle.copyWith(color: HydroticColors.gray),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
