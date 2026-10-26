import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/fr.dart';
import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Bouton SOS à maintenir (prototype : `.ringwrap` `.ringbtn`).
/// L'anneau se remplit en 3 s pendant l'appui ; relâché avant, il se vide et rien n'est envoyé.
class SosHoldButton extends StatefulWidget {
  const SosHoldButton({
    super.key,
    required this.onComplete,
    this.holdDuration = const Duration(seconds: 3),
  });

  final VoidCallback onComplete;
  final Duration holdDuration;

  @override
  State<SosHoldButton> createState() => SosHoldButtonState();
}

/// État public : le mode démo déclenche le maintien avec [demarrerMaintien].
class SosHoldButtonState extends State<SosHoldButton> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.holdDuration)
    ..addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      setState(() => _pressed = false);
      widget.onComplete();
    });
  bool _pressed = false;

  /// Démarre le maintien sans appui réel (mode démo) ; il se termine seul après 3 s.
  void demarrerMaintien() => _down();

  void _down() {
    setState(() => _pressed = true);
    _controller.forward();
  }

  void _up() {
    setState(() => _pressed = false);
    if (!_controller.isCompleted) _controller.animateBack(0, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: Fr.sosSemantique,
      excludeSemantics: true,
      onLongPress: widget.onComplete,
      child: Listener(
        onPointerDown: (_) => _down(),
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _up(),
        child: SizedBox(
          width: HydroticSizes.sosRing,
          height: HydroticSizes.sosRing,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: _RingPainter(_controller))),
              AnimatedScale(
                scale: _pressed ? .95 : 1,
                duration: const Duration(milliseconds: 190),
                child: Container(
                  width: HydroticSizes.sosButton,
                  height: HydroticSizes.sosButton,
                  decoration: const BoxDecoration(color: HydroticColors.riskRouge, shape: BoxShape.circle),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Fr.sos,
                        style: HydroticText.riskTitle.copyWith(fontSize: 30, color: HydroticColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Fr.maintenir3s,
                        style: HydroticText.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: HydroticColors.white.withValues(alpha: .9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fond rouge pâle (r = 85) et anneau de progression (épaisseur 8, départ en haut).
class _RingPainter extends CustomPainter {
  _RingPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final rayon = size.width * 85 / 190;
    canvas.drawCircle(centre, rayon, Paint()..color = HydroticColors.statusRecuBg);
    if (progress.value == 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: rayon),
      -math.pi / 2,
      2 * math.pi * progress.value,
      false,
      Paint()
        ..color = HydroticColors.riskRouge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
