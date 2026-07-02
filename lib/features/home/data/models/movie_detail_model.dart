import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/movie_detail.dart';
import 'genre_model.dart';

part 'movie_detail_model.freezed.dart';
part 'movie_detail_model.g.dart';

/// Modelo de detalle (Freezed). Espeja la respuesta de TMDB (`movie/{id}`) y se
/// transpone a la entidad `MovieDetail` con [toEntity]. No extiende la entidad
/// porque la forma del JSON difiere (los géneros vienen como `[{id, name}]`).
@freezed
class MovieDetailModel with _$MovieDetailModel {
  const MovieDetailModel._();

  const factory MovieDetailModel({
    required int id,
    required String title,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'vote_average') @Default(0.0) double voteAverage,
    @Default('') String overview,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    @Default(<GenreModel>[]) List<GenreModel> genres,
  }) = _MovieDetailModel;

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) => _$MovieDetailModelFromJson(json);

  /// Mapeo modelo → entidad de dominio (géneros → nombres).
  MovieDetail toEntity() => MovieDetail(
        id: id,
        title: title,
        posterPath: posterPath,
        voteAverage: voteAverage,
        overview: overview,
        releaseDate: releaseDate,
        runtime: runtime,
        genres: genres.map((g) => g.name).toList(),
      );
}
