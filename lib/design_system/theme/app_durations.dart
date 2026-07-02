/// Duraciones de animación del design system.
///
/// Sigue la guía de micro-interacciones (150–300ms) de `ui-ux-pro-max`:
/// las transiciones de entrada deben sentirse ágiles y las de salida más
/// rápidas que las de entrada.
abstract final class AppDurations {
  /// Micro-interacciones (press, hover, cambios de color).
  static const Duration fast = Duration(milliseconds: 150);

  /// Transiciones estándar (aparición de contenido, expand/collapse).
  static const Duration base = Duration(milliseconds: 250);

  /// Transiciones complejas (hero, sheets). Nunca > 500ms.
  static const Duration slow = Duration(milliseconds: 400);

  /// Debounce por defecto de la barra de búsqueda.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Periodo del efecto shimmer de los skeletons.
  static const Duration shimmer = Duration(milliseconds: 1200);
}
