import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/data/models/movie_detail_model.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/enums/movie_genre.dart';

import '../../../../fixtures/json_fixtures.dart';

void main() {
  group('MovieDetailModel.fromJson', () {
    test('es-un MovieDetail y mapea campos base + backdrop_path', () {
      final MovieDetailModel model = MovieDetailModel.fromJson(movieDetailJson());

      expect(model, isA<MovieDetail>());
      expect(model.id, 42);
      expect(model.title, 'Inception');
      expect(model.posterPath, '/inception.jpg');
      expect(model.backdropPath, '/inception_bg.jpg');
      expect(model.runtime, 148);
      expect(model.releaseDate, '2010-07-16');
    });

    test('GenresConverter mapea [{id,name}] → List<MovieGenre> por id', () {
      final MovieDetailModel model = MovieDetailModel.fromJson(movieDetailJson());
      expect(model.genres, [MovieGenre.scienceFiction, MovieGenre.thriller]);
    });

    test('géneros ausentes → lista vacía', () {
      final Map<String, dynamic> json = movieDetailJson()..remove('genres');
      final MovieDetailModel model = MovieDetailModel.fromJson(json);
      expect(model.genres, isEmpty);
    });

    test('género con id desconocido → unknown', () {
      final Map<String, dynamic> json = movieDetailJson()
        ..['genres'] = [
          {'id': -1, 'name': 'Raro'},
        ];
      final MovieDetailModel model = MovieDetailModel.fromJson(json);
      expect(model.genres, [MovieGenre.unknown]);
    });
  });
}
