import 'package:equatable/equatable.dart';

/// Entidad de dominio de un ítem del catálogo. Clase inmutable para poder ser
/// **extendida por el modelo de data** (LSP): un `MovieModel` es un `Movie`.
class Movie extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;

  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage = 0,
  });

  @override
  List<Object?> get props => [id, title, posterPath, voteAverage];
}
