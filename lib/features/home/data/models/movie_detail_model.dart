import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/movie_detail.dart';
import '../../domain/enums/movie_genre.dart';

part 'movie_detail_model.g.dart';

/// Modelo de detalle que **extiende** `MovieDetail` (LSP): es-un `MovieDetail`,
/// así el repositorio lo devuelve directo como entidad. `fromJson` generado por
/// json_serializable; los géneros se mapean con [GenresConverter].
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false, converters: [GenresConverter()])
class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.backdropPath,
    super.voteAverage,
    super.overview,
    super.releaseDate,
    super.runtime,
    super.genres,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) => _$MovieDetailModelFromJson(json);
}

/// Convierte los géneros de TMDB (`[{id, name}]`) a `List<MovieGenre>` (por id).
class GenresConverter implements JsonConverter<List<MovieGenre>, List<dynamic>?> {
  const GenresConverter();

  @override
  List<MovieGenre> fromJson(List<dynamic>? json) =>
      json == null ? const [] : json.map((g) => MovieGenre.fromId((g as Map<String, dynamic>)['id'] as int)).toList();

  @override
  List<dynamic> toJson(List<MovieGenre> genres) => genres.map((g) => {'id': g.id, 'name': g.label}).toList();
}
