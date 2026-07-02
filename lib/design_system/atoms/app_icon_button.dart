import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón de ícono del design system con área táctil garantizada (>= 44dp),
/// feedback de press y `tooltip`/semántica accesible obligatoria.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  /// Etiqueta accesible (obligatoria: no hay texto visible).
  final String semanticLabel;

  final Color? color;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.color,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: semanticLabel,
      icon: Icon(icon, size: iconSize),
      color: color ?? AppColors.textPrimary,
      // Área táctil mínima 44x44 aunque el ícono sea pequeño.
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      splashRadius: 24,
    );
  }
}
