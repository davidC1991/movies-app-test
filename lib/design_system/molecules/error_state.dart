import 'package:flutter/material.dart';

import '../atoms/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Estado de error reutilizable con ruta de recuperación (reintentar).
/// Sigue la guía UX: el mensaje explica el problema y ofrece una acción clara.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              message,
              variant: AppTextVariant.bodyLarge,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
