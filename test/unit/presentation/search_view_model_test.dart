import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/home/presentation/viewmodels/search_view_model.dart';
import 'package:movies/features/home/presentation/viewmodels/states/paged_movies_state.dart';

import '../../fixtures/movie_fixtures.dart';
import '../../helpers/mocks.mocks.dart';
import '../../helpers/provider_test_utils.dart';

void main() {
  late MockMovieRepository repository;

  setUp(() => repository = MockMovieRepository());

  UISuccess<PagedMoviesState> success(container) =>
      container.read(searchViewModelProvider) as UISuccess<PagedMoviesState>;

  group('SearchViewModel — transiciones de estado (US1)', () {
    test('UILoading → UISuccess con resultados', () async {
      when(repository.search('batman', page: 1))
          .thenAnswer((_) async => pageResult([1, 2]));

      final container = createContainer(repository);
      final states = recordStates(container, searchViewModelProvider);

      await container.read(searchViewModelProvider.notifier).search('batman');

      expect(states.any((s) => s is UILoading<PagedMoviesState>), isTrue);
      expect(states.whereType<UIFail<PagedMoviesState>>(), isEmpty);
      expect(states.last, isA<UISuccess<PagedMoviesState>>());
      expect((states.last as UISuccess<PagedMoviesState>).data.items.map((m) => m.id), [1, 2]);
    });

    test('UILoading → UIFail ante error de red', () async {
      when(repository.search('x', page: 1)).thenThrow(Exception('net'));

      final container = createContainer(repository);
      final states = recordStates(container, searchViewModelProvider);

      await container.read(searchViewModelProvider.notifier).search('x');

      expect(states.any((s) => s is UILoading<PagedMoviesState>), isTrue);
      expect(states.last, isA<UIFail<PagedMoviesState>>());
    });
  });

  group('SearchViewModel — reglas de negocio (US2)', () {
    test('término en blanco = sin búsqueda (no llama al repositorio)', () async {
      final container = createContainer(repository);
      await container.read(searchViewModelProvider.notifier).search('   ');

      expect(success(container).data.items, isEmpty);
      verifyNever(repository.search(any, page: anyNamed('page')));
    });

    test('sin coincidencias → éxito vacío', () async {
      when(repository.search('zzz', page: 1)).thenAnswer((_) async => pageResult([]));

      final container = createContainer(repository);
      await container.read(searchViewModelProvider.notifier).search('zzz');

      expect(success(container).data.items, isEmpty);
    });

    test('clear restaura la vista por defecto', () async {
      when(repository.search('batman', page: 1)).thenAnswer((_) async => pageResult([1]));

      final container = createContainer(repository);
      final notifier = container.read(searchViewModelProvider.notifier);
      await notifier.search('batman');
      notifier.clear();

      expect(success(container).data.items, isEmpty);
    });

    test('búsquedas encadenadas: prevalece el último término', () async {
      when(repository.search('slow', page: 1)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => pageResult([1])),
      );
      when(repository.search('fast', page: 1)).thenAnswer((_) async => pageResult([2]));

      final container = createContainer(repository);
      final notifier = container.read(searchViewModelProvider.notifier);

      final slow = notifier.search('slow');
      final fast = notifier.search('fast');
      await Future.wait([slow, fast]);

      expect(success(container).data.items.map((m) => m.id), [2]);
    });
  });

  group('SearchViewModel — paginación (US2)', () {
    test('loadMore anexa la siguiente página de resultados', () async {
      when(repository.search('batman', page: 1))
          .thenAnswer((_) async => pageResult([1, 2], page: 1, hasMore: true));
      when(repository.search('batman', page: 2))
          .thenAnswer((_) async => pageResult([3], page: 2, hasMore: false));

      final container = createContainer(repository);
      final notifier = container.read(searchViewModelProvider.notifier);
      await notifier.search('batman');
      await notifier.loadMore();

      expect(success(container).data.items.map((m) => m.id), [1, 2, 3]);
      expect(success(container).data.hasMore, isFalse);
    });

    test('loadMore no hace nada sin búsqueda activa', () async {
      final container = createContainer(repository);
      await container.read(searchViewModelProvider.notifier).loadMore();
      verifyNever(repository.search(any, page: anyNamed('page')));
    });

    test('tras error de paginación no re-lanza; retryLoadMore reintenta', () async {
      when(repository.search('batman', page: 1))
          .thenAnswer((_) async => pageResult([1], page: 1, hasMore: true));
      when(repository.search('batman', page: 2)).thenThrow(Exception('net'));

      final container = createContainer(repository);
      final notifier = container.read(searchViewModelProvider.notifier);
      await notifier.search('batman');
      await notifier.loadMore(); // falla → loadMoreError
      await notifier.loadMore(); // bloqueado por el guard
      verify(repository.search('batman', page: 2)).called(1);
      expect(success(container).data.loadMoreError, isTrue);

      // retryLoadMore fuerza el reintento (ahora responde bien).
      reset(repository);
      when(repository.search('batman', page: 2))
          .thenAnswer((_) async => pageResult([2], page: 2, hasMore: false));
      await notifier.retryLoadMore();
      expect(success(container).data.items.map((m) => m.id), [1, 2]);
    });
  });
}
