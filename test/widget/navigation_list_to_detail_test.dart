import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies/design_system/design_system.dart';
import 'package:movies/features/home/domain/entities/movie.dart';
import 'package:movies/features/home/domain/entities/movie_detail.dart';
import 'package:movies/features/home/domain/entities/page_result.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/navigation/app_router.dart';
import 'package:movies/navigation/route_paths.dart';

class MockMovieUseCases extends Mock implements MovieUseCases {}

PageResult<Movie> _page(List<int> ids) => PageResult(
      items: [for (final id in ids) Movie(id: id, title: 'M$id', voteAverage: 7)],
      page: 1,
      hasMore: false,
    );

void main() {
  testWidgets('desde el catálogo se navega al detalle y se puede volver',
      (tester) async {
    final useCases = MockMovieUseCases();
    when(() => useCases.getPopular(page: 1)).thenAnswer((_) async => _page([1]));
    when(() => useCases.getTopRated(page: 1)).thenAnswer((_) async => _page([2]));
    when(() => useCases.getDetail(1)).thenAnswer(
      (_) async => const MovieDetail(id: 1, title: 'M1', overview: 'Sinopsis de M1'),
    );

    AppRouter.setup();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [movieUseCasesProvider.overrideWithValue(useCases)],
        child: MaterialApp(
          theme: AppTheme.dark,
          initialRoute: RoutePaths.home,
          onGenerateRoute: AppRouter.router.generator,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    // Toca la primera tarjeta del catálogo.
    await tester.tap(find.byType(MediaCard).first);
    await tester.pumpAndSettle();

    // Se abrió el detalle.
    expect(find.text('Sinopsis'), findsOneWidget);

    // Volver regresa al catálogo.
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Populares'), findsOneWidget);
  });
}
