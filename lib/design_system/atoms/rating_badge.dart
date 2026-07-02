import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Insignia de calificación (estrella dorada + valor). Reutilizable sobre
/// pósters, en el detalle o en cualquier fila de metadatos.
///
/// El fondo semitransparente garantiza legibilidad AA aun sobre imágenes.
class RatingBadge extends StatelessWidget {
  /// Valor de 0 a 10 (escala TMDB).
  final double value;

  /// Compacto (sobre póster) vs. normal (detalle).
  final bool compact;

  const RatingBadge({super.key, required this.value, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 12 : 16;
    final TextStyle textStyle =
        (compact ? AppTypography.labelSmall : AppTypography.labelLarge)
            .copyWith(color: AppColors.textPrimary);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.scrim,
        borderRadius: AppRadius.brSm,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
          vertical: compact ? 2 : AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: iconSize, color: AppColors.rating),
            const SizedBox(width: AppSpacing.xs),
            Text(value.toStringAsFixed(1), style: textStyle),
          ],
        ),
      ),
    );
  }
}
