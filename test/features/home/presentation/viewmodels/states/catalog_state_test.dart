import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/presentation/viewmodels/states/catalog_state.dart';
import 'package:movies/features/home/presentation/viewmodels/states/paged_movies_state.dart';

import '../../../../../fixtures/movie_fixtures.dart';

void main() {
  group('CatalogState', () {
    final popular = PagedMoviesState.fromPage(pageResult([1]));
    final topRated = PagedMoviesState.fromPage(pageResult([9]));

    test('copyWith reemplaza solo popular', () {
      final state = CatalogState(popular: popular, topRated: topRated);
      final next = PagedMoviesState.fromPage(pageResult([2, 3]));
      final updated = state.copyWith(popular: next);
      expect(updated.popular, next);
      expect(updated.topRated, topRated);
    });

    test('copyWith reemplaza solo topRated', () {
      final state = CatalogState(popular: popular, topRated: topRated);
      final next = PagedMoviesState.fromPage(pageResult([8]));
      final updated = state.copyWith(topRated: next);
      expect(updated.popular, popular);
      expect(updated.topRated, next);
    });

    test('igualdad por props', () {
      expect(
        CatalogState(popular: popular, topRated: topRated),
        CatalogState(popular: popular, topRated: topRated),
      );
    });
  });
}
