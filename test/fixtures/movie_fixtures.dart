import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';
import 'package:movies/features/home/domain/enums/movie_genre.dart';

/// Entidades de ejemplo reutilizables en las pruebas.

Movie movie(int id, {String? title, double rating = 7.5}) =>
    Movie(id: id, title: title ?? 'Película $id', posterPath: '/p$id.jpg', voteAverage: rating);

List<Movie> movies(List<int> ids) => [for (final id in ids) movie(id)];

/// Página de resultados con [ids]; [hasMore] indica si quedan más páginas.
PageResult<Movie> pageResult(List<int> ids, {int page = 1, bool hasMore = false}) =>
    PageResult(items: movies(ids), page: page, hasMore: hasMore);

const MovieDetail movieDetailFixture = MovieDetail(
  id: 42,
  title: 'Inception',
  posterPath: '/inception.jpg',
  backdropPath: '/inception_bg.jpg',
  voteAverage: 8.3,
  overview: 'Un ladrón roba secretos del subconsciente.',
  releaseDate: '2010-07-16',
  runtime: 148,
  genres: [MovieGenre.scienceFiction, MovieGenre.thriller],
);
