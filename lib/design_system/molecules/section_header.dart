import 'package:flutter/material.dart';

import '../atoms/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Encabezado de sección (título de una fila/carrusel Netflix), con una
/// acción opcional a la derecha (p. ej. "Ver todo").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              title,
              variant: AppTextVariant.titleLarge,
              maxLines: 1,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: AppText(
                actionLabel!,
                variant: AppTextVariant.labelLarge,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
