import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/core/api/remote/api_response.dart';
import 'package:movies/features/home/data/datasources/movie_data_source.dart';
import 'package:movies/features/home/data/models/movie_model.dart';
import 'package:movies/features/home/data/repositories/movie_repository_remote.dart';
import 'package:movies/features/home/domain/entities/movie.dart';

class MockMovieDataSource extends Mock implements MovieDataSource {}

void main() {
  late MockMovieDataSource dataSource;
  late MovieRepositoryRemote repository;

  setUp(() {
    dataSource = MockMovieDataSource();
    repository = MovieRepositoryRemote(dataSource);
  });

  test('success: mapea model→entidad y devuelve List<Movie>', () async {
    when(
      () => dataSource.getMovies(),
    ).thenAnswer((_) async => SuccessApiResponse([const MovieModel(id: 7, title: 'Parasite')]));

    final result = await repository.getMovies();

    expect(result, const [Movie(id: 7, title: 'Parasite')]);
  });

  test('empty: devuelve lista vacía', () async {
    when(() => dataSource.getMovies()).thenAnswer((_) async => EmptyApiResponse<List<MovieModel>>());

    final result = await repository.getMovies();

    expect(result, isEmpty);
  });

  test('error: lanza ErrorApiResponse', () async {
    when(
      () => dataSource.getMovies(),
    ).thenAnswer((_) async => ErrorApiResponse<List<MovieModel>>(httpErrorMessage: 'boom', httpStatusCode: 500));

    expect(() => repository.getMovies(), throwsA(isA<ErrorApiResponse<List<MovieModel>>>()));
  });
}
