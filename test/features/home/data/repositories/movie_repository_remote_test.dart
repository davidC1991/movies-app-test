import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/core/api/remote/api_response.dart';
import 'package:movies/features/home/data/models/movie_detail_model.dart';
import 'package:movies/features/home/data/models/movie_model.dart';
import 'package:movies/features/home/data/models/movie_response_model.dart';
import 'package:movies/features/home/data/repositories/movie_repository_remote.dart';
import 'package:movies/features/home/domain/enums/movie_genre.dart';

import '../../../../helpers/mocks.mocks.dart';

MovieResponseModel _response({int page = 1, int totalPages = 3}) => MovieResponseModel(
      page: page,
      totalPages: totalPages,
      results: const [
        MovieModel(id: 1, title: 'A', posterPath: '/a.jpg', voteAverage: 7),
        MovieModel(id: 2, title: 'B'),
      ],
    );

void main() {
  late MockMovieDataSource dataSource;
  late MovieRepositoryRemote repository;

  // `ApiResponse` es sealed: mockito no puede autogenerar un dummy, así que se
  // registra uno para poder stubbear los métodos del data source.
  setUpAll(() {
    provideDummy<ApiResponse<MovieResponseModel>>(EmptyApiResponse<MovieResponseModel>());
    provideDummy<ApiResponse<MovieDetailModel>>(EmptyApiResponse<MovieDetailModel>());
  });

  setUp(() {
    dataSource = MockMovieDataSource();
    repository = MovieRepositoryRemote(dataSource);
  });

  group('getPopular / _toPageResult', () {
    test('success → PageResult con items y hasMore = page < totalPages', () async {
      when(dataSource.getPopular(page: 1))
          .thenAnswer((_) async => SuccessApiResponse(_response(page: 1, totalPages: 3)));

      final result = await repository.getPopular(page: 1);

      expect(result.items.map((m) => m.id), [1, 2]);
      expect(result.page, 1);
      expect(result.hasMore, isTrue);
    });

    test('última página → hasMore = false', () async {
      when(dataSource.getPopular(page: 3))
          .thenAnswer((_) async => SuccessApiResponse(_response(page: 3, totalPages: 3)));

      final result = await repository.getPopular(page: 3);
      expect(result.hasMore, isFalse);
    });

    test('empty → PageResult vacío', () async {
      when(dataSource.getPopular(page: 1))
          .thenAnswer((_) async => EmptyApiResponse<MovieResponseModel>());

      final result = await repository.getPopular(page: 1);
      expect(result.items, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('error → lanza ErrorApiResponse', () async {
      when(dataSource.getPopular(page: 1)).thenAnswer(
        (_) async => ErrorApiResponse<MovieResponseModel>(
          httpErrorMessage: 'boom',
          httpStatusCode: 500,
        ),
      );

      expect(() => repository.getPopular(page: 1), throwsA(isA<ErrorApiResponse>()));
    });
  });

  group('getDetail', () {
    test('success → MovieDetail (el modelo es-un MovieDetail)', () async {
      const detail = MovieDetailModel(
        id: 42,
        title: 'Inception',
        genres: [MovieGenre.scienceFiction],
      );
      when(dataSource.getDetail(42)).thenAnswer((_) async => SuccessApiResponse(detail));

      final result = await repository.getDetail(42);
      expect(result.id, 42);
      expect(result.title, 'Inception');
    });

    test('empty → lanza (sin datos de la película)', () async {
      when(dataSource.getDetail(1))
          .thenAnswer((_) async => EmptyApiResponse<MovieDetailModel>());

      expect(() => repository.getDetail(1), throwsA(isA<ErrorApiResponse>()));
    });

    test('error → lanza ErrorApiResponse', () async {
      when(dataSource.getDetail(1)).thenAnswer(
        (_) async => ErrorApiResponse<MovieDetailModel>(
          httpErrorMessage: 'boom',
          httpStatusCode: 500,
        ),
      );

      expect(() => repository.getDetail(1), throwsA(isA<ErrorApiResponse>()));
    });
  });
}
