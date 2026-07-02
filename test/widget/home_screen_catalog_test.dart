import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/design_system/design_system.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/ui/home_screen.dart';

class MockMovieUseCases extends Mock implements MovieUseCases {}

// Pósters nulos → placeholder, sin peticiones de red en el test.
PageResult<Movie> _page(List<int> ids) => PageResult(
      items: [for (final id in ids) Movie(id: id, title: 'M$id', voteAverage: 7)],
      page: 1,
      hasMore: false,
    );

void main() {
  testWidgets('HomeScreen muestra las filas Populares y Mejor valoradas',
      (tester) async {
    final useCases = MockMovieUseCases();
    when(() => useCases.getPopular(page: 1)).thenAnswer((_) async => _page([1, 2]));
    when(() => useCases.getTopRated(page: 1)).thenAnswer((_) async => _page([9, 8]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [movieUseCasesProvider.overrideWithValue(useCases)],
        child: MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      ),
    );

    // Resuelve la carga inicial del catálogo.
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Populares'), findsOneWidget);
    expect(find.text('Mejor valoradas'), findsOneWidget);
    expect(find.byType(MediaCard), findsWidgets);
  });
}
