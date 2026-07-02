import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/api/api_config.dart';

void main() {
  group('ApiConfig.posterUrl', () {
    test('construye la URL con el tamaño de póster', () {
      expect(ApiConfig.posterUrl('/abc.jpg'),
          'https://image.tmdb.org/t/p/${ApiConfig.posterSize}/abc.jpg');
    });

    test('null o vacío → null', () {
      expect(ApiConfig.posterUrl(null), isNull);
      expect(ApiConfig.posterUrl(''), isNull);
    });
  });

  group('ApiConfig.backdropUrl', () {
    test('construye la URL con el tamaño de backdrop', () {
      expect(ApiConfig.backdropUrl('/bg.jpg'),
          'https://image.tmdb.org/t/p/${ApiConfig.backdropSize}/bg.jpg');
    });

    test('null o vacío → null', () {
      expect(ApiConfig.backdropUrl(null), isNull);
      expect(ApiConfig.backdropUrl(''), isNull);
    });
  });
}
