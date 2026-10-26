import 'package:flutter/material.dart';

import '../data/models/niveau_risque.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';
import '../theme/risk_colors.dart';

/// Carte du niveau de risque (prototype : `.risk`). Fondu de 500 ms quand le niveau change.
class RiskCard extends StatelessWidget {
  const RiskCard({
    super.key,
    required this.niveau,
    required this.surTitre,
    required this.titre,
    required this.message,
    this.height = HydroticSizes.riskCard,
  });

  /// Version compacte (96 px, écran Alertes) : sans le message.
  const RiskCard.compact({
    super.key,
    required this.niveau,
    required this.surTitre,
    required this.titre,
  })  : message = '',
        height = 96;

  final NiveauRisque niveau;

  /// Affiché en majuscules (« DEMAIN · NIVEAU ORANGE »).
  final String surTitre;
  final String titre;
  final String message;

  /// 148 px sur l'accueil, 96 px dans la version compacte (écran Alertes).
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: [surTitre, titre, message].where((t) => t.isNotEmpty).join('. '),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HydroticRadius.card),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [...previous, if (current != null) current],
            ),
            child: _Layer(
              key: ValueKey((niveau, titre)),
              niveau: niveau,
              surTitre: surTitre,
              titre: titre,
              message: message,
            ),
          ),
        ),
      ),
    );
  }
}

class _Layer extends StatelessWidget {
  const _Layer({
    super.key,
    required this.niveau,
    required this.surTitre,
    required this.titre,
    required this.message,
  });

  final NiveauRisque niveau;
  final String surTitre;
  final String titre;
  final String message;

  @override
  Widget build(BuildContext context) {
    const white = HydroticColors.white;
    return ColoredBox(
      color: niveau.couleur,
      child: Padding(
        padding: const EdgeInsets.all(HydroticSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              surTitre.toUpperCase(),
              style: HydroticText.overline.copyWith(color: white.withValues(alpha: .9)),
            ),
            const SizedBox(height: 4),
            Text(
              titre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HydroticText.riskTitle.copyWith(color: white),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  message,
                  overflow: TextOverflow.fade,
                  style: HydroticText.body.copyWith(color: white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
