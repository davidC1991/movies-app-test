import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/ui/home_screen.dart';
import 'package:movies/navigation/app_router.dart';
import 'package:movies/navigation/route_paths.dart';
import 'package:movies/design_system/design_system.dart';

import '../test/fixtures/movie_fixtures.dart';
import '../test/helpers/mocks.mocks.dart';

/// Pruebas de integración (driver de Flutter) de los recorridos principales,
/// con el repositorio simulado (sin red).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMovieRepository repository;

  // El router de fluro es un singleton estático: registrar las rutas una sola
  // vez (definirlas dos veces lanza "Default route was already defined").
  setUpAll(AppRouter.setup);

  setUp(() {
    repository = MockMovieRepository();
    when(repository.getPopular(page: anyNamed('page')))
        .thenAnswer((_) async => pageResult([1, 2, 3]));
    when(repository.getTopRated(page: anyNamed('page')))
        .thenAnswer((_) async => pageResult([9, 8, 7]));
    when(repository.search(any, page: anyNamed('page')))
        .thenAnswer((_) async => pageResult([1]));
    when(repository.getDetail(any)).thenAnswer((_) async => movieDetailFixture);
  });

  Widget buildApp() => ProviderScope(
        overrides: [
          movieUseCasesProvider.overrideWithValue(MovieUseCases(repository)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          initialRoute: RoutePaths.home,
          onGenerateRoute: AppRouter.router.generator,
        ),
      );

  testWidgets('catálogo: muestra las categorías Populares y Mejor valoradas',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Populares'), findsOneWidget);
    expect(find.text('Mejor valoradas'), findsOneWidget);
    expect(find.byType(MediaCard), findsWidgets);
  });

  testWidgets('navegación: listado → detalle → volver', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MediaCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Sinopsis'), findsOneWidget); // pantalla de detalle

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Populares'), findsOneWidget); // de vuelta al catálogo
  });

  testWidgets('búsqueda: escribir un término muestra resultados', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'batman');
    // Espera el debounce (400 ms) + la respuesta simulada.
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MediaCard), findsWidgets);
  });
}
