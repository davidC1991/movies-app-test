import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/api/remote/api_response.dart';
import 'package:movies/features/home/data/datasources/movie_data_source.dart';
import 'package:movies/features/home/data/models/movie_model.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';
import 'package:movies/features/home/presentation/ui/home_screen.dart';

/// Fake del data source para no golpear la red en el test.
class _FakeMovieDataSource implements MovieDataSource {
  @override
  Future<ApiResponse<List<MovieModel>>> getMovies() async =>
      SuccessApiResponse([const MovieModel(id: 2, title: 'Inception')]);
}

void main() {
  testWidgets('HomeScreen: el botón dispara el flujo y muestra las películas', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [movieDataSourceProvider.overrideWithValue(_FakeMovieDataSource())],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Estado inicial: instrucción visible, sin lista.
    expect(find.text('Pulsa el botón para cargar películas'), findsOneWidget);

    // Pulsar el botón de verificación y dejar resolver el Future.
    await tester.tap(find.text('Verificar'));
    await tester.pumpAndSettle();

    // Success: se listan las películas.
    expect(find.text('Inception'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
