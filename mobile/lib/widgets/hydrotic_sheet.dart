import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';

/// Feuille du bas (prototype : `.sheet` + `.grab`). Monte depuis le bas en 600 ms à l'apparition.
/// À placer en bas d'un [Stack] (au-dessus de la barre de navigation si besoin).
class HydroticSheet extends StatefulWidget {
  const HydroticSheet({
    super.key,
    required this.child,
    this.bottomPadding = HydroticSpacing.sheetPadding,
    this.animate = true,
  });

  final Widget child;
  final double bottomPadding;

  /// Faux : la feuille est affichée directement (captures, catalogue).
  final bool animate;

  @override
  State<HydroticSheet> createState() => _HydroticSheetState();
}

class _HydroticSheetState extends State<HydroticSheet> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: widget.animate ? 0.0 : 1.0,
  );
  late final _offset = Tween(begin: const Offset(0, 1.1), end: Offset.zero).animate(
    CurvedAnimation(parent: _controller, curve: const Cubic(.2, .9, .3, 1)),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          HydroticSpacing.sheetPadding,
          16,
          HydroticSpacing.sheetPadding,
          widget.bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: HydroticColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(HydroticRadius.sheet)),
          boxShadow: HydroticShadows.sheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: HydroticSpacing.gapL),
                decoration: BoxDecoration(
                  color: HydroticColors.slateLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
