import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

/// Modelo de datos que **extiende la entidad** `Movie` (LSP): un `MovieModel`
/// *es un* `Movie`, así el repositorio puede devolverlo directamente como entidad.
/// `fromJson`/`toJson` los genera json_serializable.
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.voteAverage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);
}
