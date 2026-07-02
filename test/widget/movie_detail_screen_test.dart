import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/design_system/design_system.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/enums/movie_genre.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/ui/movie_detail_screen.dart';

class MockMovieUseCases extends Mock implements MovieUseCases {}

void main() {
  testWidgets('MovieDetailScreen renderiza título, géneros y sinopsis',
      (tester) async {
    final useCases = MockMovieUseCases();
    const detail = MovieDetail(
      id: 1,
      title: 'Inception',
      overview: 'Un ladrón roba secretos del subconsciente.',
      voteAverage: 8.3,
      releaseDate: '2010-07-16',
      runtime: 148,
      genres: [MovieGenre.scienceFiction, MovieGenre.thriller],
    );
    when(() => useCases.getDetail(1)).thenAnswer((_) async => detail);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [movieUseCasesProvider.overrideWithValue(useCases)],
        child: const MaterialApp(home: MovieDetailScreen(movieId: 1)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Sinopsis'), findsOneWidget);
    expect(find.text('Ciencia ficción'), findsOneWidget);
    expect(find.byType(AppChip), findsNWidgets(2));
  });
}
