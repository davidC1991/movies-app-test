// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieDetailModelImpl _$$MovieDetailModelImplFromJson(
  Map<String, dynamic> json,
) => _$MovieDetailModelImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  posterPath: json['poster_path'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  overview: json['overview'] as String? ?? '',
  releaseDate: json['release_date'] as String?,
  runtime: (json['runtime'] as num?)?.toInt(),
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GenreModel>[],
);

Map<String, dynamic> _$$MovieDetailModelImplToJson(
  _$MovieDetailModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'poster_path': instance.posterPath,
  'vote_average': instance.voteAverage,
  'overview': instance.overview,
  'release_date': instance.releaseDate,
  'runtime': instance.runtime,
  'genres': instance.genres,
};
