import 'package:flutter/material.dart';

import '../theme/hydrotic_colors.dart';
import '../theme/hydrotic_sizes.dart';
import '../theme/hydrotic_text.dart';

/// Champ de saisie : fond slateXLight, rayon 14, sans bordure (aucune vérification en phase 1).
class HydroticTextField extends StatelessWidget {
  const HydroticTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final bord = OutlineInputBorder(
      borderRadius: BorderRadius.circular(HydroticRadius.mini),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: HydroticText.body.copyWith(color: HydroticColors.gray),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: HydroticText.body.copyWith(color: HydroticColors.grayLight),
        filled: true,
        fillColor: HydroticColors.slateXLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: bord,
        enabledBorder: bord,
        focusedBorder: bord.copyWith(borderSide: const BorderSide(color: HydroticColors.slate)),
      ),
    );
  }
}
