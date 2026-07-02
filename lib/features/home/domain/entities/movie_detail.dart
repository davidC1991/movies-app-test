import 'package:equatable/equatable.dart';

/// Entidad de dominio con la información ampliada de una película (endpoint de detalle).
class MovieDetail extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String overview;
  final String? releaseDate;
  final int? runtime;
  final List<String> genres;

  const MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage = 0,
    this.overview = '',
    this.releaseDate,
    this.runtime,
    this.genres = const [],
  });

  @override
  List<Object?> get props => [id, title, posterPath, voteAverage, overview, releaseDate, runtime, genres];
}
