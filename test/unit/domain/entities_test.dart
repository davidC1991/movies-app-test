import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';

void main() {
  group('Igualdad de entidades (Equatable)', () {
    test('Movie es igual por props', () {
      const a = Movie(id: 1, title: 'A', posterPath: '/a.jpg', voteAverage: 7);
      const b = Movie(id: 1, title: 'A', posterPath: '/a.jpg', voteAverage: 7);
      const c = Movie(id: 2, title: 'A');
      expect(a, b);
      expect(a == c, isFalse);
    });

    test('MovieDetail es igual por props', () {
      const a = MovieDetail(id: 1, title: 'A', overview: 'x');
      const b = MovieDetail(id: 1, title: 'A', overview: 'x');
      const c = MovieDetail(id: 1, title: 'B', overview: 'x');
      expect(a, b);
      expect(a == c, isFalse);
    });

    test('PageResult es igual por props', () {
      const a = PageResult<Movie>(items: [], page: 1, hasMore: true);
      const b = PageResult<Movie>(items: [], page: 1, hasMore: true);
      const c = PageResult<Movie>(items: [], page: 2, hasMore: true);
      expect(a, b);
      expect(a == c, isFalse);
    });
  });
}
