import 'package:freezed_annotation/freezed_annotation.dart';

import 'movie_model.dart';

part 'movie_response_model.freezed.dart';
part 'movie_response_model.g.dart';

/// Envoltura de la respuesta paginada de TMDB (p. ej. `/movie/popular`),
/// que devuelve la lista bajo la clave `results`.
@freezed
class MovieResponseModel with _$MovieResponseModel {
  const factory MovieResponseModel({
    required int page,
    required List<MovieModel> results,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _MovieResponseModel;

  factory MovieResponseModel.fromJson(Map<String, dynamic> json) => _$MovieResponseModelFromJson(json);
}
