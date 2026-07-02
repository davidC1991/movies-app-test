// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovieResponseModel _$MovieResponseModelFromJson(Map<String, dynamic> json) {
  return _MovieResponseModel.fromJson(json);
}

/// @nodoc
mixin _$MovieResponseModel {
  int get page => throw _privateConstructorUsedError;
  List<MovieModel> get results => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pages')
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this MovieResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieResponseModelCopyWith<MovieResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieResponseModelCopyWith<$Res> {
  factory $MovieResponseModelCopyWith(
    MovieResponseModel value,
    $Res Function(MovieResponseModel) then,
  ) = _$MovieResponseModelCopyWithImpl<$Res, MovieResponseModel>;
  @useResult
  $Res call({
    int page,
    List<MovieModel> results,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class _$MovieResponseModelCopyWithImpl<$Res, $Val extends MovieResponseModel>
    implements $MovieResponseModelCopyWith<$Res> {
  _$MovieResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? results = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<MovieModel>,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieResponseModelImplCopyWith<$Res>
    implements $MovieResponseModelCopyWith<$Res> {
  factory _$$MovieResponseModelImplCopyWith(
    _$MovieResponseModelImpl value,
    $Res Function(_$MovieResponseModelImpl) then,
  ) = __$$MovieResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int page,
    List<MovieModel> results,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class __$$MovieResponseModelImplCopyWithImpl<$Res>
    extends _$MovieResponseModelCopyWithImpl<$Res, _$MovieResponseModelImpl>
    implements _$$MovieResponseModelImplCopyWith<$Res> {
  __$$MovieResponseModelImplCopyWithImpl(
    _$MovieResponseModelImpl _value,
    $Res Function(_$MovieResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? results = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$MovieResponseModelImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<MovieModel>,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieResponseModelImpl implements _MovieResponseModel {
  const _$MovieResponseModelImpl({
    required this.page,
    required final List<MovieModel> results,
    @JsonKey(name: 'total_pages') this.totalPages = 1,
  }) : _results = results;

  factory _$MovieResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieResponseModelImplFromJson(json);

  @override
  final int page;
  final List<MovieModel> _results;
  @override
  List<MovieModel> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  @JsonKey(name: 'total_pages')
  final int totalPages;

  @override
  String toString() {
    return 'MovieResponseModel(page: $page, results: $results, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieResponseModelImpl &&
            (identical(other.page, page) || other.page == page) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    page,
    const DeepCollectionEquality().hash(_results),
    totalPages,
  );

  /// Create a copy of MovieResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieResponseModelImplCopyWith<_$MovieResponseModelImpl> get copyWith =>
      __$$MovieResponseModelImplCopyWithImpl<_$MovieResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieResponseModelImplToJson(this);
  }
}

abstract class _MovieResponseModel implements MovieResponseModel {
  const factory _MovieResponseModel({
    required final int page,
    required final List<MovieModel> results,
    @JsonKey(name: 'total_pages') final int totalPages,
  }) = _$MovieResponseModelImpl;

  factory _MovieResponseModel.fromJson(Map<String, dynamic> json) =
      _$MovieResponseModelImpl.fromJson;

  @override
  int get page;
  @override
  List<MovieModel> get results;
  @override
  @JsonKey(name: 'total_pages')
  int get totalPages;

  /// Create a copy of MovieResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieResponseModelImplCopyWith<_$MovieResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
