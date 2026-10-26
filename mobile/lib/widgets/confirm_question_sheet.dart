import 'package:flutter/material.dart';

import '../data/models/confirmation.dart';
import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';
import 'hydrotic_sheet.dart';

/// Contenu de l'état « Merci » après une réponse.
class MerciContenu {
  const MerciContenu({required this.message, required this.metaGauche, required this.metaDroite});

  /// Texte riche (« Rue Ministre : **inondation confirmée** par 8 habitants… »).
  final InlineSpan message;
  final String metaGauche;
  final String metaDroite;
}

/// Feuille de confirmation communautaire (prototype : `.q .qs .ans .meta`).
/// État « question » tant que [merci] est nul, puis fondu vers l'état « Merci ».
class ConfirmQuestionSheet extends StatelessWidget {
  const ConfirmQuestionSheet({
    super.key,
    required this.question,
    required this.sousTitre,
    required this.metaGauche,
    required this.metaDroite,
    required this.onReponse,
    this.merci,
    this.animate = true,
  });

  final String question;
  final String sousTitre;
  final String metaGauche;
  final String metaDroite;
  final ValueChanged<OuiNonInconnu> onReponse;
  final MerciContenu? merci;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final merci = this.merci;
    return HydroticSheet(
      animate: animate,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 350),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topLeft,
          children: [...previous, if (current != null) current],
        ),
        child: merci == null ? _question() : _merci(merci),
      ),
    );
  }

  Widget _question() {
    return Column(
      key: const ValueKey('question'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: HydroticText.sheetTitle.copyWith(color: HydroticColors.gray)),
        const SizedBox(height: 6),
        Text(sousTitre, style: HydroticText.caption.copyWith(color: HydroticColors.grayLight)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                label: Fr.oui,
                background: HydroticColors.slate,
                foreground: HydroticColors.white,
                onTap: () => onReponse(OuiNonInconnu.oui),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AnswerButton(
                label: Fr.non,
                background: HydroticColors.slateLight,
                foreground: HydroticColors.slateDark,
                onTap: () => onReponse(OuiNonInconnu.non),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AnswerButton(
                label: Fr.jeNeSaisPas,
                foreground: HydroticColors.grayLight,
                outlined: true,
                onTap: () => onReponse(OuiNonInconnu.inconnu),
              ),
            ),
          ],
        ),
        _Meta(gauche: metaGauche, droite: metaDroite),
      ],
    );
  }

  Widget _merci(MerciContenu merci) {
    return Column(
      key: const ValueKey('merci'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: HydroticColors.slate, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 20, color: HydroticColors.white),
            ),
            const SizedBox(width: HydroticSpacing.gapM),
            Expanded(
              child: Text(Fr.merci, style: HydroticText.sheetTitle.copyWith(color: HydroticColors.gray)),
            ),
          ],
        ),
        const SizedBox(height: HydroticSpacing.gapM),
        Text.rich(merci.message, style: HydroticText.caption.copyWith(color: HydroticColors.grayLight)),
        const SizedBox(height: 14),
        _Meta(gauche: merci.metaGauche, droite: merci.metaDroite),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.background = HydroticColors.white,
    this.outlined = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  /// « Je ne sais pas » : contour, texte 12/600.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      side: outlined ? const BorderSide(color: HydroticColors.slateLight) : BorderSide.none,
      borderRadius: BorderRadius.circular(HydroticRadius.button),
    );
    final style = outlined
        ? HydroticText.caption.copyWith(fontWeight: FontWeight.w600)
        : HydroticText.button;
    return Material(
      color: background,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HydroticSizes.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            child: Center(
              child: Text(label, maxLines: 1, style: style.copyWith(color: foreground)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.gauche, required this.droite});

  final String gauche;
  final String droite;

  @override
  Widget build(BuildContext context) {
    final style = HydroticText.small.copyWith(color: HydroticColors.grayLight);
    return Padding(
      padding: const EdgeInsets.only(top: HydroticSpacing.gapL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(gauche, style: style), Text(droite, style: style)],
      ),
    );
  }
}
