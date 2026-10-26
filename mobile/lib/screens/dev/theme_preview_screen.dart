import 'package:flutter/material.dart';

import '../../theme/hydrotic_colors.dart';
import '../../theme/hydrotic_sizes.dart';
import '../../theme/hydrotic_text.dart';

// Page de développement (étape 2) : aperçu des couleurs et des styles générés.
// Remplacée par le catalogue de composants à l'étape 4.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  static const _brand = <(String, Color)>[
    ('slate', HydroticColors.slate),
    ('slateDark', HydroticColors.slateDark),
    ('slateLight', HydroticColors.slateLight),
    ('slateXLight', HydroticColors.slateXLight),
    ('gray', HydroticColors.gray),
    ('grayLight', HydroticColors.grayLight),
    ('deep', HydroticColors.deep),
  ];

  // Couleur de risque toujours accompagnée de son mot.
  static const _risk = <(String, Color)>[
    ('Normal', HydroticColors.riskVert),
    ('Vigilance', HydroticColors.riskJaune),
    ('Risque élevé', HydroticColors.riskOrange),
    ('Danger', HydroticColors.riskRouge),
  ];

  static const _styles = <(String, TextStyle)>[
    ('riskTitle 26/800', HydroticText.riskTitle),
    ('screenTitle 20/800', HydroticText.screenTitle),
    ('sheetTitle 17/800', HydroticText.sheetTitle),
    ('greeting 16/700', HydroticText.greeting),
    ('statValue 15/700', HydroticText.statValue),
    ('button 14/700', HydroticText.button),
    ('sectionTitle 13/700', HydroticText.sectionTitle),
    ('body 13/400', HydroticText.body),
    ('caption 12/400', HydroticText.caption),
    ('small 11/400', HydroticText.small),
    ('navLabel 10/400', HydroticText.navLabel),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HydroticSpacing.screenPadding),
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo_hydrotic_icon.png',
                  width: HydroticSizes.avatarLogo,
                  height: HydroticSizes.avatarLogo,
                ),
                const SizedBox(width: HydroticSpacing.gapM),
                const Text('Hydrotic CI', style: HydroticText.greeting),
              ],
            ),
            const SizedBox(height: HydroticSpacing.gapL),
            const Text('Couleurs de marque', style: HydroticText.sectionTitle),
            const SizedBox(height: HydroticSpacing.gapS),
            Wrap(
              spacing: HydroticSpacing.gapS,
              runSpacing: HydroticSpacing.gapS,
              children: [for (final (name, color) in _brand) _Swatch(name: name, color: color)],
            ),
            const SizedBox(height: HydroticSpacing.gapL),
            const Text('Niveaux de risque', style: HydroticText.sectionTitle),
            const SizedBox(height: HydroticSpacing.gapS),
            for (final (label, color) in _risk)
              Container(
                margin: const EdgeInsets.only(bottom: HydroticSpacing.gapS),
                padding: const EdgeInsets.all(HydroticSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(HydroticRadius.mini),
                ),
                child: Text(
                  label,
                  style: HydroticText.statValue.copyWith(color: HydroticColors.white),
                ),
              ),
            const SizedBox(height: HydroticSpacing.gapL),
            const Text('Typographie (Inter)', style: HydroticText.sectionTitle),
            const SizedBox(height: HydroticSpacing.gapS),
            Text('Demain · niveau orange'.toUpperCase(), style: HydroticText.overline),
            for (final (name, style) in _styles) Text(name, style: style),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(HydroticRadius.navIcon),
            border: Border.all(color: HydroticColors.slateLight),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: HydroticText.navLabel),
      ],
    );
  }
}
