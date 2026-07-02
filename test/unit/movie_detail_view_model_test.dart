import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/viewmodels/movie_detail_view_model.dart';

class MockMovieUseCases extends Mock implements MovieUseCases {}

void main() {
  late MockMovieUseCases useCases;

  setUp(() => useCases = MockMovieUseCases());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [movieUseCasesProvider.overrideWithValue(useCases)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('MovieDetailViewModel', () {
    test('carga el detalle en éxito', () async {
      const detail = MovieDetail(id: 42, title: 'Inception', overview: 'Sueños');
      when(() => useCases.getDetail(42)).thenAnswer((_) async => detail);

      final container = makeContainer();
      await container.read(movieDetailViewModelProvider(42).notifier).retry();

      final state = container.read(movieDetailViewModelProvider(42));
      expect(state, isA<UISuccess<MovieDetail>>());
      expect((state as UISuccess<MovieDetail>).data.title, 'Inception');
    });

    test('estado de error cuando falla la carga', () async {
      when(() => useCases.getDetail(7)).thenThrow(Exception('boom'));

      final container = makeContainer();
      await container.read(movieDetailViewModelProvider(7).notifier).retry();

      expect(container.read(movieDetailViewModelProvider(7)),
          isA<UIFail<MovieDetail>>());
    });
  });
}
