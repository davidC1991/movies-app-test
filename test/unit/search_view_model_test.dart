import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/viewmodels/paged_movies.dart';
import 'package:movies/features/home/presentation/viewmodels/search_view_model.dart';

class MockMovieUseCases extends Mock implements MovieUseCases {}

PageResult<Movie> _page(List<int> ids, {int page = 1, bool hasMore = false}) =>
    PageResult(
      items: [for (final id in ids) Movie(id: id, title: 'M$id', voteAverage: 7)],
      page: page,
      hasMore: hasMore,
    );

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

  UISuccess<PagedMovies> readSuccess(ProviderContainer c) =>
      c.read(searchViewModelProvider) as UISuccess<PagedMovies>;

  group('SearchViewModel', () {
    test('estado idle inicial es éxito vacío (sin búsqueda)', () {
      final container = makeContainer();
      final state = container.read(searchViewModelProvider);
      expect(state, isA<UISuccess<PagedMovies>>());
      expect((state as UISuccess<PagedMovies>).data.items, isEmpty);
    });

    test('búsqueda con resultados', () async {
      when(() => useCases.search('batman', page: 1))
          .thenAnswer((_) async => _page([1, 2]));

      final container = makeContainer();
      await container.read(searchViewModelProvider.notifier).search('batman');

      expect(readSuccess(container).data.items.map((m) => m.id), [1, 2]);
    });

    test('término en blanco se trata como "sin búsqueda" (restaura idle)', () async {
      final container = makeContainer();
      await container.read(searchViewModelProvider.notifier).search('   ');

      expect(readSuccess(container).data.items, isEmpty);
      verifyNever(() => useCases.search(any(), page: any(named: 'page')));
    });

    test('sin coincidencias → éxito vacío', () async {
      when(() => useCases.search('zzz', page: 1))
          .thenAnswer((_) async => _page([]));

      final container = makeContainer();
      await container.read(searchViewModelProvider.notifier).search('zzz');

      expect(readSuccess(container).data.items, isEmpty);
    });

    test('error de red → estado de error', () async {
      when(() => useCases.search('x', page: 1)).thenThrow(Exception('net'));

      final container = makeContainer();
      await container.read(searchViewModelProvider.notifier).search('x');

      expect(container.read(searchViewModelProvider), isA<UIFail<PagedMovies>>());
    });

    test('clear restaura la vista por defecto', () async {
      when(() => useCases.search('batman', page: 1))
          .thenAnswer((_) async => _page([1]));

      final container = makeContainer();
      final notifier = container.read(searchViewModelProvider.notifier);
      await notifier.search('batman');
      notifier.clear();

      expect(readSuccess(container).data.items, isEmpty);
    });

    test('búsquedas encadenadas: prevalece el último término', () async {
      // "slow" tarda; "fast" responde antes. El resultado final debe ser "fast".
      when(() => useCases.search('slow', page: 1)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => _page([1])),
      );
      when(() => useCases.search('fast', page: 1))
          .thenAnswer((_) async => _page([2]));

      final container = makeContainer();
      final notifier = container.read(searchViewModelProvider.notifier);

      final slow = notifier.search('slow');
      final fast = notifier.search('fast');
      await Future.wait([slow, fast]);

      expect(readSuccess(container).data.items.map((m) => m.id), [2]);
    });
  });
}
