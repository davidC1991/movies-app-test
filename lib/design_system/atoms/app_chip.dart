import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Chip de etiqueta (p. ej. géneros de una película). Puede ser estático o,
/// si recibe [onTap], seleccionable (se resalta con el acento Netflix).
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? AppColors.accent : AppColors.surfaceElevated;
    final Color fg = selected ? AppColors.onAccent : AppColors.textSecondary;

    final AnimatedContainer chip = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.brPill,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Text(label, style: AppTypography.labelSmall.copyWith(color: fg)),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brPill,
      child: chip,
    );
  }
}
