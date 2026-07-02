import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';

void main() {
  group('Igualdad de entidades (Equatable)', () {
    test('Movie es igual por props', () {
      const Movie a = Movie(id: 1, title: 'A', posterPath: '/a.jpg', voteAverage: 7);
      const Movie b = Movie(id: 1, title: 'A', posterPath: '/a.jpg', voteAverage: 7);
      const Movie c = Movie(id: 2, title: 'A');
      expect(a, b);
      expect(a == c, isFalse);
    });

    test('MovieDetail es igual por props', () {
      const MovieDetail a = MovieDetail(id: 1, title: 'A', overview: 'x');
      const MovieDetail b = MovieDetail(id: 1, title: 'A', overview: 'x');
      const MovieDetail c = MovieDetail(id: 1, title: 'B', overview: 'x');
      expect(a, b);
      expect(a == c, isFalse);
    });

    test('PageResult es igual por props', () {
      const PageResult<Movie> a = PageResult<Movie>(items: [], page: 1, hasMore: true);
      const PageResult<Movie> b = PageResult<Movie>(items: [], page: 1, hasMore: true);
      const PageResult<Movie> c = PageResult<Movie>(items: [], page: 2, hasMore: true);
      expect(a, b);
      expect(a == c, isFalse);
    });
  });
}
