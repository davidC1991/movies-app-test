import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// Variantes tipográficas expuestas por [AppText], mapeadas a los tokens
/// de [AppTypography]. Evita usar `TextStyle` sueltos en los widgets.
enum AppTextVariant {
  displayLarge,
  headlineLarge,
  headlineMedium,
  titleLarge,
  titleMedium,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelSmall,
}

/// Átomo de texto del design system. Encapsula la escala tipográfica para
/// que las pantallas nunca declaren tamaños/pesos a mano.
class AppText extends StatelessWidget {
  final String data;
  final AppTextVariant variant;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const AppText(
    this.data, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.fontWeight,
  });

  TextStyle get _baseStyle => switch (variant) {
        AppTextVariant.displayLarge => AppTypography.displayLarge,
        AppTextVariant.headlineLarge => AppTypography.headlineLarge,
        AppTextVariant.headlineMedium => AppTypography.headlineMedium,
        AppTextVariant.titleLarge => AppTypography.titleLarge,
        AppTextVariant.titleMedium => AppTypography.titleMedium,
        AppTextVariant.bodyLarge => AppTypography.bodyLarge,
        AppTextVariant.bodyMedium => AppTypography.bodyMedium,
        AppTextVariant.bodySmall => AppTypography.bodySmall,
        AppTextVariant.labelLarge => AppTypography.labelLarge,
        AppTextVariant.labelSmall => AppTypography.labelSmall,
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: _baseStyle.copyWith(color: color, fontWeight: fontWeight),
    );
  }
}
