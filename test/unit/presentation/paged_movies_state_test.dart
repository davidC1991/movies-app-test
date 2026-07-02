import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/presentation/viewmodels/states/paged_movies_state.dart';

import '../../fixtures/movie_fixtures.dart';

void main() {
  group('PagedMoviesState', () {
    test('fromPage construye la primera página', () {
      final state = PagedMoviesState.fromPage(pageResult([1, 2], page: 1, hasMore: true));
      expect(state.items.map((m) => m.id), [1, 2]);
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreError, isFalse);
    });

    test('startLoadingMore marca carga y limpia error', () {
      const base = PagedMoviesState(items: [], page: 1, hasMore: true, loadMoreError: true);
      final loading = base.startLoadingMore();
      expect(loading.isLoadingMore, isTrue);
      expect(loading.loadMoreError, isFalse);
    });

    test('appendPage anexa ítems y actualiza page/hasMore', () {
      final base = PagedMoviesState.fromPage(pageResult([1, 2], page: 1, hasMore: true));
      final next = base.appendPage(pageResult([3, 4], page: 2, hasMore: false));
      expect(next.items.map((m) => m.id), [1, 2, 3, 4]);
      expect(next.page, 2);
      expect(next.hasMore, isFalse);
      expect(next.isLoadingMore, isFalse);
      expect(next.loadMoreError, isFalse);
    });

    test('failLoadingMore marca error y detiene carga', () {
      const base = PagedMoviesState(items: [], page: 1, hasMore: true, isLoadingMore: true);
      final failed = base.failLoadingMore();
      expect(failed.isLoadingMore, isFalse);
      expect(failed.loadMoreError, isTrue);
    });
  });
}
