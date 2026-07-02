import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens tipográficos del design system.
///
/// Font pairing de la skill `ui-ux-pro-max`: **"Modern Dark Cinema (Inter
/// System)"** — una sola familia (Inter) con jerarquía por peso y tracking:
/// 700/-0.5 para displays, 600 para títulos, 400 para cuerpo, 500 uppercase
/// +tracking para labels.
///
/// Nota de implementación: no se declara `fontFamily: 'Inter'` para no
/// depender de un asset/paquete no incluido aún; se usa la familia del
/// sistema con la MISMA escala y pesos. Para activar Inter real basta con
/// añadir la fuente al `pubspec.yaml` y setear [fontFamily] abajo.
abstract final class AppTypography {
  /// Familia tipográfica. `null` = fuente por defecto del sistema
  /// (fallback correcto de Inter). Cambiar a `'Inter'` al bundlear la fuente.
  static const String? fontFamily = null;

  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Título de sección (encabezado de carrusel Netflix).
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Labels / metadatos en mayúsculas con tracking (chips, badges).
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  /// `TextTheme` de Material construido a partir de los tokens, para que
  /// `Theme.of(context).textTheme` refleje la escala del design system.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );
}
