import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/home/presentation/viewmodels/catalog_view_model.dart';
import 'package:movies/features/home/presentation/viewmodels/states/catalog_state.dart';

import '../../../../fixtures/movie_fixtures.dart';
import '../../../../helpers/mocks.mocks.dart';
import '../../../../helpers/provider_test_utils.dart';

void main() {
  late MockMovieRepository repository;

  setUp(() => repository = MockMovieRepository());

  group('CatalogViewModel — transiciones de estado (US1)', () {
    test('UILoading → UISuccess(CatalogState) en el camino feliz', () async {
      when(repository.getPopular(page: anyNamed('page')))
          .thenAnswer((_) async => pageResult([1, 2]));
      when(repository.getTopRated(page: anyNamed('page')))
          .thenAnswer((_) async => pageResult([9, 8]));

      final ProviderContainer container = createContainer(repository);
      final List<UIState<CatalogState>> states = recordStates(container, catalogViewModelProvider);

      // El primer estado observado (fireImmediately) es la carga inicial.
      expect(states.first, isA<UILoading<CatalogState>>());

      await container.read(catalogViewModelProvider.notifier).retry();

      expect(states.whereType<UIFail<CatalogState>>(), isEmpty,
          reason: 'el camino feliz no debe emitir error');
      final UISuccess<CatalogState> success = states.whereType<UISuccess<CatalogState>>().last;
      expect(success.data.popular.items.map((m) => m.id), [1, 2]);
      expect(success.data.topRated.items.map((m) => m.id), [9, 8]);
    });

    test('UILoading → UIFail cuando el repositorio lanza', () async {
      when(repository.getPopular(page: anyNamed('page'))).thenThrow(Exception('boom'));
      when(repository.getTopRated(page: anyNamed('page')))
          .thenAnswer((_) async => pageResult([9]));

      final ProviderContainer container = createContainer(repository);
      final List<UIState<CatalogState>> states = recordStates(container, catalogViewModelProvider);

      await container.read(catalogViewModelProvider.notifier).retry();

      expect(states.any((s) => s is UILoading<CatalogState>), isTrue);
      expect(states.last, isA<UIFail<CatalogState>>());
    });
  });

  group('CatalogViewModel — reglas de negocio (US2)', () {
    test('loadMorePopular anexa la siguiente página', () async {
      when(repository.getPopular(page: 1))
          .thenAnswer((_) async => pageResult([1, 2], page: 1, hasMore: true));
      when(repository.getTopRated(page: 1))
          .thenAnswer((_) async => pageResult([9], page: 1, hasMore: false));
      when(repository.getPopular(page: 2))
          .thenAnswer((_) async => pageResult([3, 4], page: 2, hasMore: false));

      final ProviderContainer container = createContainer(repository);
      final CatalogViewModel notifier = container.read(catalogViewModelProvider.notifier);
      await notifier.retry();
      await notifier.loadMorePopular();

      final CatalogState data = (container.read(catalogViewModelProvider) as UISuccess<CatalogState>).data;
      expect(data.popular.items.map((m) => m.id), [1, 2, 3, 4]);
      expect(data.popular.hasMore, isFalse);
    });

    test('no pagina si no hay más páginas', () async {
      when(repository.getPopular(page: 1))
          .thenAnswer((_) async => pageResult([1], page: 1, hasMore: false));
      when(repository.getTopRated(page: 1))
          .thenAnswer((_) async => pageResult([9], page: 1, hasMore: false));

      final ProviderContainer container = createContainer(repository);
      final CatalogViewModel notifier = container.read(catalogViewModelProvider.notifier);
      await notifier.retry();
      await notifier.loadMorePopular();

      verifyNever(repository.getPopular(page: 2));
    });

    test('no re-lanza la petición tras un error de paginación (loadMoreError)', () async {
      when(repository.getPopular(page: 1))
          .thenAnswer((_) async => pageResult([1], page: 1, hasMore: true));
      when(repository.getTopRated(page: 1))
          .thenAnswer((_) async => pageResult([9], page: 1, hasMore: false));
      when(repository.getPopular(page: 2)).thenThrow(Exception('net'));

      final ProviderContainer container = createContainer(repository);
      final CatalogViewModel notifier = container.read(catalogViewModelProvider.notifier);
      await notifier.retry();
      await notifier.loadMorePopular(); // falla → loadMoreError = true
      await notifier.loadMorePopular(); // bloqueado por el guard

      // page:2 solo se intentó una vez pese a dos llamadas.
      verify(repository.getPopular(page: 2)).called(1);
      final CatalogState data = (container.read(catalogViewModelProvider) as UISuccess<CatalogState>).data;
      expect(data.popular.loadMoreError, isTrue);
    });
  });
}
