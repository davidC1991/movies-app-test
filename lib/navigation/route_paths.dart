/// Constantes de rutas globales de la app.
/// Cada feature referencia aquí sus paths para registrarlos en el router global.
class RoutePaths {
  const RoutePaths._();

  static const String home = '/';

  /// Base de la ruta de detalle de película. El patrón registrado es
  /// `/movie/:id`; usa [movieDetailOf] para construir la ruta concreta.
  static const String movieDetail = '/movie';

  /// Ruta de detalle para una película concreta (p. ej. `/movie/550`).
  static String movieDetailOf(int id) => '$movieDetail/$id';
}
