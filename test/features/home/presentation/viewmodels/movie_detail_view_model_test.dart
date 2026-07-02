import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/presentation/viewmodels/movie_detail_view_model.dart';

import '../../../../fixtures/movie_fixtures.dart';
import '../../../../helpers/mocks.mocks.dart';
import '../../../../helpers/provider_test_utils.dart';

void main() {
  late MockMovieRepository repository;

  setUp(() => repository = MockMovieRepository());

  group('MovieDetailViewModel — transiciones de estado (US1)', () {
    test('UILoading → UISuccess(MovieDetail)', () async {
      when(repository.getDetail(42)).thenAnswer((_) async => movieDetailFixture);

      final ProviderContainer container = createContainer(repository);
      final List<UIState<MovieDetail>> states = recordStates(container, movieDetailViewModelProvider(42));

      await container.read(movieDetailViewModelProvider(42).notifier).retry();

      expect(states.any((s) => s is UILoading<MovieDetail>), isTrue);
      expect(states.whereType<UIFail<MovieDetail>>(), isEmpty);
      expect(states.last, isA<UISuccess<MovieDetail>>());
      expect((states.last as UISuccess<MovieDetail>).data.title, 'Inception');
    });

    test('UILoading → UIFail cuando falla la carga', () async {
      when(repository.getDetail(7)).thenThrow(Exception('boom'));

      final ProviderContainer container = createContainer(repository);
      final List<UIState<MovieDetail>> states = recordStates(container, movieDetailViewModelProvider(7));

      await container.read(movieDetailViewModelProvider(7).notifier).retry();

      expect(states.last, isA<UIFail<MovieDetail>>());
    });
  });

  group('MovieDetailViewModel — reglas de negocio (US2)', () {
    test('retry recarga el detalle tras un error', () async {
      when(repository.getDetail(42))
          .thenThrow(Exception('primero falla'));

      final ProviderContainer container = createContainer(repository);
      final MovieDetailViewModel notifier = container.read(movieDetailViewModelProvider(42).notifier);
      await notifier.retry();
      expect(container.read(movieDetailViewModelProvider(42)), isA<UIFail<MovieDetail>>());

      // Ahora el repositorio responde bien y el reintento tiene éxito.
      reset(repository);
      when(repository.getDetail(42)).thenAnswer((_) async => movieDetailFixture);
      await notifier.retry();

      expect(container.read(movieDetailViewModelProvider(42)), isA<UISuccess<MovieDetail>>());
    });
  });
}
