import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/home/domain/usecases/movie_use_cases.dart';
import 'package:movies/features/home/presentation/providers/home_providers.dart';

import 'mocks.mocks.dart';

/// Crea un `ProviderContainer` de test con el repositorio **mockeado**: se
/// sobrescribe `movieUseCasesProvider` con `MovieUseCases(repository)` para
/// ejercitar el caso de uso real sobre un repositorio simulado. Registra el
/// `dispose` automáticamente (aislamiento por prueba).
ProviderContainer createContainer(MockMovieRepository repository) {
  final container = ProviderContainer(
    overrides: [
      movieUseCasesProvider.overrideWithValue(MovieUseCases(repository)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Escucha [provider] y acumula en la lista devuelta **cada estado emitido**,
/// incluyendo el estado inicial (`fireImmediately: true`). Es el mecanismo con
/// el que las pruebas de ViewModel aseveran las transiciones de `UIState`.
List<T> recordStates<T>(
  ProviderContainer container,
  ProviderListenable<T> provider,
) {
  final states = <T>[];
  final sub = container.listen<T>(
    provider,
    (_, next) => states.add(next),
    fireImmediately: true,
  );
  addTearDown(sub.close);
  return states;
}
