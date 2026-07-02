import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Velo de gradiente para garantizar legibilidad del texto sobre imágenes
/// (pósters, backdrops). Cumple la guía de contraste: el texto blanco se
/// apoya siempre en la zona oscura del gradiente.
class GradientScrim extends StatelessWidget {
  /// Colores del gradiente (por defecto, el scrim de póster).
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientScrim({
    super.key,
    this.colors = AppColors.posterScrim,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  /// Variante para el backdrop del detalle (funde con el fondo de la app).
  const GradientScrim.backdrop({super.key})
      : colors = AppColors.backdropScrim,
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: begin, end: end, colors: colors),
      ),
    );
  }
}
