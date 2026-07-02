// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovieDetailModel _$MovieDetailModelFromJson(Map<String, dynamic> json) {
  return _MovieDetailModel.fromJson(json);
}

/// @nodoc
mixin _$MovieDetailModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_path')
  String? get posterPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average')
  double get voteAverage => throw _privateConstructorUsedError;
  String get overview => throw _privateConstructorUsedError;
  @JsonKey(name: 'release_date')
  String? get releaseDate => throw _privateConstructorUsedError;
  int? get runtime => throw _privateConstructorUsedError;
  List<GenreModel> get genres => throw _privateConstructorUsedError;

  /// Serializes this MovieDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieDetailModelCopyWith<MovieDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieDetailModelCopyWith<$Res> {
  factory $MovieDetailModelCopyWith(
    MovieDetailModel value,
    $Res Function(MovieDetailModel) then,
  ) = _$MovieDetailModelCopyWithImpl<$Res, MovieDetailModel>;
  @useResult
  $Res call({
    int id,
    String title,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'vote_average') double voteAverage,
    String overview,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    List<GenreModel> genres,
  });
}

/// @nodoc
class _$MovieDetailModelCopyWithImpl<$Res, $Val extends MovieDetailModel>
    implements $MovieDetailModelCopyWith<$Res> {
  _$MovieDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? posterPath = freezed,
    Object? voteAverage = null,
    Object? overview = null,
    Object? releaseDate = freezed,
    Object? runtime = freezed,
    Object? genres = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            posterPath: freezed == posterPath
                ? _value.posterPath
                : posterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            voteAverage: null == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            overview: null == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String,
            releaseDate: freezed == releaseDate
                ? _value.releaseDate
                : releaseDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            runtime: freezed == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int?,
            genres: null == genres
                ? _value.genres
                : genres // ignore: cast_nullable_to_non_nullable
                      as List<GenreModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieDetailModelImplCopyWith<$Res>
    implements $MovieDetailModelCopyWith<$Res> {
  factory _$$MovieDetailModelImplCopyWith(
    _$MovieDetailModelImpl value,
    $Res Function(_$MovieDetailModelImpl) then,
  ) = __$$MovieDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'vote_average') double voteAverage,
    String overview,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    List<GenreModel> genres,
  });
}

/// @nodoc
class __$$MovieDetailModelImplCopyWithImpl<$Res>
    extends _$MovieDetailModelCopyWithImpl<$Res, _$MovieDetailModelImpl>
    implements _$$MovieDetailModelImplCopyWith<$Res> {
  __$$MovieDetailModelImplCopyWithImpl(
    _$MovieDetailModelImpl _value,
    $Res Function(_$MovieDetailModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? posterPath = freezed,
    Object? voteAverage = null,
    Object? overview = null,
    Object? releaseDate = freezed,
    Object? runtime = freezed,
    Object? genres = null,
  }) {
    return _then(
      _$MovieDetailModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        posterPath: freezed == posterPath
            ? _value.posterPath
            : posterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        voteAverage: null == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        overview: null == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String,
        releaseDate: freezed == releaseDate
            ? _value.releaseDate
            : releaseDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        runtime: freezed == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int?,
        genres: null == genres
            ? _value._genres
            : genres // ignore: cast_nullable_to_non_nullable
                  as List<GenreModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieDetailModelImpl extends _MovieDetailModel {
  const _$MovieDetailModelImpl({
    required this.id,
    required this.title,
    @JsonKey(name: 'poster_path') this.posterPath,
    @JsonKey(name: 'vote_average') this.voteAverage = 0.0,
    this.overview = '',
    @JsonKey(name: 'release_date') this.releaseDate,
    this.runtime,
    final List<GenreModel> genres = const <GenreModel>[],
  }) : _genres = genres,
       super._();

  factory _$MovieDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieDetailModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @override
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @override
  @JsonKey()
  final String overview;
  @override
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @override
  final int? runtime;
  final List<GenreModel> _genres;
  @override
  @JsonKey()
  List<GenreModel> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  @override
  String toString() {
    return 'MovieDetailModel(id: $id, title: $title, posterPath: $posterPath, voteAverage: $voteAverage, overview: $overview, releaseDate: $releaseDate, runtime: $runtime, genres: $genres)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieDetailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            const DeepCollectionEquality().equals(other._genres, _genres));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    posterPath,
    voteAverage,
    overview,
    releaseDate,
    runtime,
    const DeepCollectionEquality().hash(_genres),
  );

  /// Create a copy of MovieDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieDetailModelImplCopyWith<_$MovieDetailModelImpl> get copyWith =>
      __$$MovieDetailModelImplCopyWithImpl<_$MovieDetailModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieDetailModelImplToJson(this);
  }
}

abstract class _MovieDetailModel extends MovieDetailModel {
  const factory _MovieDetailModel({
    required final int id,
    required final String title,
    @JsonKey(name: 'poster_path') final String? posterPath,
    @JsonKey(name: 'vote_average') final double voteAverage,
    final String overview,
    @JsonKey(name: 'release_date') final String? releaseDate,
    final int? runtime,
    final List<GenreModel> genres,
  }) = _$MovieDetailModelImpl;
  const _MovieDetailModel._() : super._();

  factory _MovieDetailModel.fromJson(Map<String, dynamic> json) =
      _$MovieDetailModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'poster_path')
  String? get posterPath;
  @override
  @JsonKey(name: 'vote_average')
  double get voteAverage;
  @override
  String get overview;
  @override
  @JsonKey(name: 'release_date')
  String? get releaseDate;
  @override
  int? get runtime;
  @override
  List<GenreModel> get genres;

  /// Create a copy of MovieDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieDetailModelImplCopyWith<_$MovieDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
