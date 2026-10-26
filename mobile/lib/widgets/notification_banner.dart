import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Aperçu de notification simulé (prototype : `.banner`).
/// Entre par le haut, reste 2,5 s puis ressort ; un appui la fait remonter tout de suite.
/// À placer dans un [Stack] (Positioned : gauche 10, droite 10, haut 8).
class NotificationBanner extends StatefulWidget {
  const NotificationBanner({
    super.key,
    required this.titre,
    required this.titreColor,
    required this.corps,
    this.onTap,
    this.onDismissed,
    this.displayDuration = const Duration(milliseconds: 2500),
  });

  final String titre;
  final Color titreColor;
  final String corps;
  final VoidCallback? onTap;

  /// Appelé quand la bannière est sortie de l'écran.
  final VoidCallback? onDismissed;
  final Duration displayDuration;

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> with SingleTickerProviderStateMixin {
  // Durées du prototype (animation b1 : entrée 18 %, sortie 16 % de 3,2 s).
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 576),
    reverseDuration: const Duration(milliseconds: 512),
  );
  late final _offset = Tween(begin: const Offset(0, -1.4), end: Offset.zero)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  bool _sortie = false;

  @override
  void initState() {
    super.initState();
    _controller.forward().then((_) => Future.delayed(widget.displayDuration, _sortir));
  }

  Future<void> _sortir() async {
    if (_sortie || !mounted) return;
    _sortie = true;
    await _controller.reverse();
    if (mounted) widget.onDismissed?.call();
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
      child: Semantics(
        button: true,
        liveRegion: true,
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
            _sortir();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: HydroticColors.white.withValues(alpha: .97),
              borderRadius: BorderRadius.circular(HydroticRadius.chip),
              boxShadow: HydroticShadows.banner,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo_hydrotic_icon.png', width: 18, height: 18),
                    const SizedBox(width: 8),
                    Text(
                      Fr.notificationEnTete,
                      style: HydroticText.small.copyWith(color: HydroticColors.grayLight),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.titre,
                  style: HydroticText.button.copyWith(color: widget.titreColor, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.corps,
                  style: HydroticText.caption.copyWith(color: HydroticColors.gray, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
