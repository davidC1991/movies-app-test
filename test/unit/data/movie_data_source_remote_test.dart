import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/core/api/remote/api_response.dart';
import 'package:movies/features/home/data/datasources/movie_data_source_remote.dart';
import 'package:movies/features/home/data/models/movie_detail_model.dart';
import 'package:movies/features/home/data/models/movie_model.dart';
import 'package:movies/features/home/data/models/movie_response_model.dart';

import '../../helpers/mocks.mocks.dart';

void main() {
  late MockMovieService service;
  late MovieDataSourceRemote dataSource;

  setUp(() {
    service = MockMovieService();
    dataSource = MovieDataSourceRemote(service);
  });

  const response = MovieResponseModel(
    page: 1,
    totalPages: 2,
    results: [MovieModel(id: 1, title: 'A')],
  );

  test('getPopular éxito → SuccessApiResponse con el body', () async {
    when(service.getPopularMovies(page: 1)).thenAnswer((_) async => response);

    final result = await dataSource.getPopular(page: 1);

    expect(result, isA<SuccessApiResponse<MovieResponseModel>>());
    expect((result as SuccessApiResponse<MovieResponseModel>).body.results.first.id, 1);
  });

  test('getTopRated éxito → SuccessApiResponse', () async {
    when(service.getTopRatedMovies(page: 1)).thenAnswer((_) async => response);
    final result = await dataSource.getTopRated(page: 1);
    expect(result, isA<SuccessApiResponse<MovieResponseModel>>());
  });

  test('search éxito → SuccessApiResponse', () async {
    when(service.searchMovies(query: 'q', page: 1)).thenAnswer((_) async => response);
    final result = await dataSource.search('q', page: 1);
    expect(result, isA<SuccessApiResponse<MovieResponseModel>>());
  });

  test('getDetail éxito → SuccessApiResponse', () async {
    const detail = MovieDetailModel(id: 1, title: 'A');
    when(service.getMovieDetail(1)).thenAnswer((_) async => detail);
    final result = await dataSource.getDetail(1);
    expect(result, isA<SuccessApiResponse<MovieDetailModel>>());
  });

  test('DioException del service → ErrorApiResponse', () async {
    // El service (retrofit) devuelve un Future que falla (error async), no un
    // throw síncrono; así lo captura `executeApiCall`.
    when(service.searchMovies(query: 'x', page: 1)).thenAnswer(
      (_) async => throw DioException(
        requestOptions: RequestOptions(path: '/search/movie'),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await dataSource.search('x', page: 1);

    expect(result, isA<ErrorApiResponse<MovieResponseModel>>());
  });
}
