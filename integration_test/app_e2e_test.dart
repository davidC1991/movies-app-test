import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movies/app.dart';
import 'package:movies/design_system/design_system.dart';
import 'package:movies/navigation/app_router.dart';

/// Pruebas **end-to-end reales**: arrancan la app completa **sin mocks**, pegando
/// a la API real de TMDB. Requieren un `.env` con `TMDB_TOKEN` válido y conexión
/// a internet (por eso son no deterministas: las aserciones son resilientes).
///
/// Ejecutar en un emulador/dispositivo:
///   flutter test integration_test/app_e2e_test.dart -d `device`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    AppRouter.setup();
  });

  /// Bombea la UI hasta que [finder] encuentre algo o venza el [timeout]
  /// (necesario porque la respuesta de red real no es instantánea).
  Future<bool> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  }

  testWidgets('E2E: el catálogo real de TMDB carga y se navega al detalle',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoviesApp()));

    // 1) El catálogo real carga sus tarjetas (red).
    expect(await pumpUntilFound(tester, find.byType(MediaCard)), isTrue,
        reason: 'el catálogo debería cargar películas reales de TMDB');
    expect(find.text('Populares'), findsWidgets);

    // 2) Se abre el detalle de una película real.
    await tester.tap(find.byType(MediaCard).first);
    expect(await pumpUntilFound(tester, find.byTooltip('Volver')), isTrue,
        reason: 'debería abrirse la pantalla de detalle');

    // 3) Volver regresa al catálogo.
    await tester.tap(find.byTooltip('Volver'));
    expect(await pumpUntilFound(tester, find.text('Populares')), isTrue);
  });

  testWidgets('E2E: la búsqueda real devuelve resultados', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoviesApp()));
    await pumpUntilFound(tester, find.byType(MediaCard));

    await tester.enterText(find.byType(TextField), 'batman');
    // Espera el debounce (400 ms) + la respuesta real de red.
    expect(await pumpUntilFound(tester, find.byType(MediaCard)), isTrue,
        reason: 'la búsqueda real debería devolver resultados');
  });
}
