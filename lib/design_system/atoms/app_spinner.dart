import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Indicador de progreso circular del design system (acento Netflix).
/// Úsalo para cargas puntuales; para carga de contenido prefiere `Skeleton`.
class AppSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppSpinner({super.key, this.size = 28, this.strokeWidth = 2.5});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
      ),
    );
  }
}
