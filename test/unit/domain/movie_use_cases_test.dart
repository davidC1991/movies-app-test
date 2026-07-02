import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';

import '../../fixtures/movie_fixtures.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  late MockMovieRepository repository;
  late MovieUseCases useCases;

  setUp(() {
    repository = MockMovieRepository();
    useCases = MovieUseCases(repository);
  });

  group('MovieUseCases — delegación en el repositorio', () {
    test('getPopular delega con la misma página y devuelve el resultado', () async {
      final page = pageResult([1, 2]);
      when(repository.getPopular(page: 3)).thenAnswer((_) async => page);

      final result = await useCases.getPopular(page: 3);

      expect(result, page);
      verify(repository.getPopular(page: 3)).called(1);
    });

    test('getTopRated delega en el repositorio', () async {
      final page = pageResult([9]);
      when(repository.getTopRated(page: 1)).thenAnswer((_) async => page);

      final result = await useCases.getTopRated();

      expect(result, page);
      verify(repository.getTopRated(page: 1)).called(1);
    });

    test('search delega término y página', () async {
      final page = pageResult([5]);
      when(repository.search('batman', page: 2)).thenAnswer((_) async => page);

      final result = await useCases.search('batman', page: 2);

      expect(result, page);
      verify(repository.search('batman', page: 2)).called(1);
    });

    test('getDetail delega con el id', () async {
      when(repository.getDetail(42)).thenAnswer((_) async => movieDetailFixture);

      final result = await useCases.getDetail(42);

      expect(result, movieDetailFixture);
      verify(repository.getDetail(42)).called(1);
    });
  });
}
