import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/viewmodels/catalog_view_model.dart';

class MockMovieUseCases extends Mock implements MovieUseCases {}

PageResult<Movie> _page(List<int> ids, {int page = 1, bool hasMore = true}) =>
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

  group('CatalogViewModel', () {
    test('carga Popular y Top Rated en éxito', () async {
      when(() => useCases.getPopular(page: 1))
          .thenAnswer((_) async => _page([1, 2]));
      when(() => useCases.getTopRated(page: 1))
          .thenAnswer((_) async => _page([9, 8]));

      final container = makeContainer();
      final notifier = container.read(catalogViewModelProvider.notifier);
      await notifier.retry();

      final state = container.read(catalogViewModelProvider);
      expect(state, isA<UISuccess<CatalogState>>());
      final data = (state as UISuccess<CatalogState>).data;
      expect(data.popular.items.map((m) => m.id), [1, 2]);
      expect(data.topRated.items.map((m) => m.id), [9, 8]);
    });

    test('loadMorePopular anexa la siguiente página', () async {
      when(() => useCases.getPopular(page: 1))
          .thenAnswer((_) async => _page([1, 2], page: 1, hasMore: true));
      when(() => useCases.getTopRated(page: 1))
          .thenAnswer((_) async => _page([9], page: 1, hasMore: false));
      when(() => useCases.getPopular(page: 2))
          .thenAnswer((_) async => _page([3, 4], page: 2, hasMore: false));

      final container = makeContainer();
      final notifier = container.read(catalogViewModelProvider.notifier);
      await notifier.retry();
      await notifier.loadMorePopular();

      final data =
          (container.read(catalogViewModelProvider) as UISuccess<CatalogState>).data;
      expect(data.popular.items.map((m) => m.id), [1, 2, 3, 4]);
      expect(data.popular.hasMore, isFalse);
    });

    test('estado de error cuando falla la carga inicial', () async {
      when(() => useCases.getPopular(page: 1)).thenThrow(Exception('boom'));
      when(() => useCases.getTopRated(page: 1))
          .thenAnswer((_) async => _page([9]));

      final container = makeContainer();
      await container.read(catalogViewModelProvider.notifier).retry();

      expect(container.read(catalogViewModelProvider), isA<UIFail<CatalogState>>());
    });

    test('no pagina si no hay más páginas', () async {
      when(() => useCases.getPopular(page: 1))
          .thenAnswer((_) async => _page([1], page: 1, hasMore: false));
      when(() => useCases.getTopRated(page: 1))
          .thenAnswer((_) async => _page([9], page: 1, hasMore: false));

      final container = makeContainer();
      final notifier = container.read(catalogViewModelProvider.notifier);
      await notifier.retry();
      await notifier.loadMorePopular();

      verifyNever(() => useCases.getPopular(page: 2));
    });
  });
}
