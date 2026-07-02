import 'package:flutter/material.dart';

/// Tokens de color del design system (estética Netflix / Dark Mode OLED).
///
/// Basado en la paleta "Video Streaming/OTT" de la skill `ui-ux-pro-max`
/// (Cinema dark + play red), con el acento ajustado al **rojo Netflix**
/// auténtico (`#E50914`) por requisito de marca.
///
/// Regla: los widgets NO deben usar hex crudos; consumen estos tokens o,
/// preferentemente, los tokens semánticos del `ColorScheme` vía
/// `Theme.of(context).colorScheme`.
abstract final class AppColors {
  // --- Superficies (fondo casi negro, escalado por elevación) ---
  /// Fondo raíz de la app (casi negro, óptimo para OLED).
  static const Color background = Color(0xFF0B0B0B);

  /// Superficie base de tarjetas y secciones.
  static const Color surface = Color(0xFF141414);

  /// Superficie elevada (sheets, menús, hover de tarjeta).
  static const Color surfaceElevated = Color(0xFF1F1F1F);

  /// Superficie sutil para skeletons / rellenos discretos.
  static const Color surfaceMuted = Color(0xFF181818);

  // --- Acento Netflix ---
  /// Rojo Netflix (CTA, foco, indicadores activos).
  static const Color accent = Color(0xFFE50914);

  /// Rojo Netflix presionado / hover.
  static const Color accentPressed = Color(0xFFB20710);

  /// Texto/íconos sobre el acento.
  static const Color onAccent = Color(0xFFFFFFFF);

  // --- Texto ---
  /// Texto principal (blanco cálido, contraste AAA sobre fondos oscuros).
  static const Color textPrimary = Color(0xFFF5F5F5);

  /// Texto secundario (gris Netflix, contraste AA para metadatos).
  static const Color textSecondary = Color(0xFFB3B3B3);

  /// Texto terciario / deshabilitado.
  static const Color textTertiary = Color(0xFF808080);

  // --- Bordes y divisores ---
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF262626);

  // --- Rating ---
  /// Dorado de las estrellas de calificación (estilo IMDb).
  static const Color rating = Color(0xFFF5C518);

  // --- Estados semánticos ---
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  // --- Skeleton / shimmer ---
  static const Color shimmerBase = Color(0xFF1C1C1C);
  static const Color shimmerHighlight = Color(0xFF2E2E2E);

  // --- Scrims / gradientes sobre imágenes ---
  /// Scrim negro sólido para aislar contenido (modales, sheets).
  static const Color scrim = Color(0xCC000000); // 80% negro

  /// Gradiente vertical para legibilidad de texto sobre backdrops/pósters.
  /// De transparente (arriba) a casi negro (abajo).
  static const List<Color> posterScrim = [
    Color(0x00000000),
    Color(0x99000000),
    Color(0xF2000000),
  ];

  /// Gradiente de héroe para el backdrop del detalle (fusiona con el fondo).
  static const List<Color> backdropScrim = [
    Color(0x00000000),
    Color(0x660B0B0B),
    Color(0xFF0B0B0B),
  ];
}
