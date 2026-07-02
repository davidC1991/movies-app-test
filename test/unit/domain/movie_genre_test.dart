import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/domain/enums/movie_genre.dart';

void main() {
  group('MovieGenre.fromId', () {
    test('resuelve un id conocido al género correcto', () {
      expect(MovieGenre.fromId(28), MovieGenre.action);
      expect(MovieGenre.fromId(878), MovieGenre.scienceFiction);
      expect(MovieGenre.fromId(35), MovieGenre.comedy);
    });

    test('id desconocido → unknown', () {
      expect(MovieGenre.fromId(-999), MovieGenre.unknown);
      expect(MovieGenre.fromId(0), MovieGenre.unknown);
    });

    test('cada género conserva su id y etiqueta', () {
      expect(MovieGenre.action.id, 28);
      expect(MovieGenre.action.label, 'Acción');
    });
  });
}
