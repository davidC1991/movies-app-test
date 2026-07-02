import 'package:equatable/equatable.dart';

import '../enums/movie_genre.dart';

/// Entidad de dominio con la información ampliada de una película (endpoint de detalle).
class MovieDetail extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String overview;
  final String? releaseDate;
  final int? runtime;
  final List<MovieGenre> genres;

  const MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.overview = '',
    this.releaseDate,
    this.runtime,
    this.genres = const [],
  });

  @override
  List<Object?> get props =>
      [id, title, posterPath, backdropPath, voteAverage, overview, releaseDate, runtime, genres];
}
