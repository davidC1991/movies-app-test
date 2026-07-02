import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movies/design_system/design_system.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/ui/home_screen.dart';
import 'package:movies/navigation/app_router.dart';
import 'package:movies/navigation/route_paths.dart';

import '../test/fixtures/movie_fixtures.dart';
import '../test/helpers/mocks.mocks.dart';

/// PRUEBAS DE INTEGRACIÓN con **datos simulados** (repositorio mockeado, sin red).
/// Verifican que las pantallas, la navegación y los ViewModels funcionan juntos
/// de extremo a extremo, de forma **determinista** (aptas para CI, sin token ni
/// internet). El E2E contra la API real vive en `flujos_e2e_real_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integración de flujos (datos simulados / mocks)', () {
    late MockMovieRepository repository;

    // El router de fluro es un singleton estático: registrar las rutas una vez.
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

    testWidgets('el catálogo muestra las categorías Populares y Mejor valoradas',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Mejor valoradas'), findsOneWidget);
      expect(find.byType(MediaCard), findsWidgets);
    });

    testWidgets('navegación: del listado al detalle y de vuelta', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(MediaCard), findsWidgets);
    });
  });
}
