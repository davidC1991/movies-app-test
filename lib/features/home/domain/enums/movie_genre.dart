/// Géneros de película de TMDB. Ids estables de la API + etiqueta para la UI.
/// Se mapea por `id` (el nombre puede variar por idioma).
enum MovieGenre {
  action(28, 'Acción'),
  adventure(12, 'Aventura'),
  animation(16, 'Animación'),
  comedy(35, 'Comedia'),
  crime(80, 'Crimen'),
  documentary(99, 'Documental'),
  drama(18, 'Drama'),
  family(10751, 'Familia'),
  fantasy(14, 'Fantasía'),
  history(36, 'Historia'),
  horror(27, 'Terror'),
  music(10402, 'Música'),
  mystery(9648, 'Misterio'),
  romance(10749, 'Romance'),
  scienceFiction(878, 'Ciencia ficción'),
  tvMovie(10770, 'Película de TV'),
  thriller(53, 'Suspenso'),
  war(10752, 'Guerra'),
  western(37, 'Western'),
  unknown(-1, 'Desconocido');

  const MovieGenre(this.id, this.label);

  final int id;
  final String label;

  /// Resuelve el género por su id de TMDB; `unknown` si no se reconoce.
  static MovieGenre fromId(int id) =>
      MovieGenre.values.firstWhere((g) => g.id == id, orElse: () => MovieGenre.unknown);
}
