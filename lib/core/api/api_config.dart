import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de la API (TMDB). Valores compartidos por toda la app.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Base y tamaño para las imágenes de póster.
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterSize = 'w342';

  /// Read Access Token (v4) de TMDB, leído del archivo `.env`.
  static String get tmdbToken => dotenv.env['TMDB_TOKEN'] ?? '';

  /// Construye la URL de un póster a partir de su `poster_path`.
  /// Devuelve `null` si no hay ruta (para usar un placeholder).
  static String? posterUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl/$posterSize$path';
  }
}
