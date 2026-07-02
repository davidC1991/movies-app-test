import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/data/models/movie_model.dart';
import 'package:movies/features/home/data/models/movie_response_model.dart';
import 'package:movies/features/home/domain/entities/movie.dart';

import '../../../../fixtures/json_fixtures.dart';

void main() {
  group('MovieModel.fromJson', () {
    test('mapea campos snake_case y es-un Movie (LSP)', () {
      final model = MovieModel.fromJson({
        'id': 1,
        'title': 'Película 1',
        'poster_path': '/p1.jpg',
        'vote_average': 7.5,
      });

      expect(model, isA<Movie>());
      expect(model.id, 1);
      expect(model.title, 'Película 1');
      expect(model.posterPath, '/p1.jpg');
      expect(model.voteAverage, 7.5);
    });

    test('poster_path nulo se tolera', () {
      final model = MovieModel.fromJson({'id': 2, 'title': 'X', 'poster_path': null});
      expect(model.posterPath, isNull);
      expect(model.voteAverage, 0);
    });
  });

  group('MovieResponseModel.fromJson', () {
    test('mapea page, results y total_pages', () {
      final model = MovieResponseModel.fromJson(movieResponseJson(page: 2, totalPages: 5));
      expect(model.page, 2);
      expect(model.totalPages, 5);
      expect(model.results, hasLength(2));
      expect(model.results.first.id, 1);
    });

    test('total_pages ausente usa el default (1)', () {
      final model = MovieResponseModel.fromJson({'page': 1, 'results': []});
      expect(model.totalPages, 1);
    });
  });
}
