import 'package:flutter/material.dart';

/// Tokens de sombra/elevación del design system.
///
/// En dark mode la elevación se expresa sobre todo con superficies más
/// claras; las sombras se usan con moderación para dar profundidad a
/// pósters y sheets sin ensuciar el fondo negro.
abstract final class AppShadows {
  /// Sombra sutil para pósters/tarjetas del catálogo.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// Sombra pronunciada para elementos flotantes (sheets, diálogos).
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}
