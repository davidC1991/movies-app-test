// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieResponseModelImpl _$$MovieResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$MovieResponseModelImpl(
  page: (json['page'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$$MovieResponseModelImplToJson(
  _$MovieResponseModelImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'results': instance.results,
  'total_pages': instance.totalPages,
};
