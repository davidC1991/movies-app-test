import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/repositories/movie_repository.dart';
import 'package:movies/features/home/domain/usecases/get_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;
  late GetMovies useCase;

  setUp(() {
    repository = MockMovieRepository();
    useCase = GetMovies(repository);
  });

  test('devuelve la lista de entidades del repositorio', () async {
    const movies = [Movie(id: 1, title: 'Inception')];
    when(() => repository.getMovies()).thenAnswer((_) async => movies);

    final result = await useCase();

    expect(result, movies);
    verify(() => repository.getMovies()).called(1);
  });

  test('devuelve lista vacía (empty success)', () async {
    when(() => repository.getMovies()).thenAnswer((_) async => const <Movie>[]);

    final result = await useCase();

    expect(result, isEmpty);
  });

  test('propaga la excepción cuando el repositorio lanza', () async {
    when(() => repository.getMovies()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsA(isA<Exception>()));
  });
}
