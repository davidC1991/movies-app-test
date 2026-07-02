# Contract: `GetMovies` (use case)

**Layer**: domain  
**File**: `lib/features/home/domain/usecases/get_movies.dart`

## Interfaz

```dart
class GetMovies {
  final MovieRepository _repository;
  const GetMovies(this._repository);

  Future<Result<List<Movie>>> call() => _repository.getMovies();
}
```

## Contrato de comportamiento

- Delega en `MovieRepository.getMovies()` y devuelve su `Result<List<Movie>>` sin transformarlo.
- Es el **único punto de entrada** que la capa de presentación (ViewModel) invoca; la presentación **no** conoce el repositorio directamente en su lógica de negocio (lo obtiene por DI).
- Callable (`call()`) para invocación ergonómica: `await getMovies()`.

## Pruebas asociadas

`test/features/home/domain/get_movies_test.dart` (repositorio mockeado con mocktail):
- Repo devuelve `success` → el use case devuelve el mismo `success`.
- Repo devuelve `empty` → el use case devuelve `empty`.
- Repo devuelve `fail` → el use case devuelve `fail`.

---

# Contract: DI providers (presentation)

**File**: `lib/features/home/presentation/providers/home_providers.dart`

Cadena de inyección con Riverpod **manual** (referencia: `fin/auth_methods/providers`):

```dart
final movieDataSourceProvider = Provider<MovieMockDataSource>(
  (ref) => MovieMockDataSource(),
);

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepositoryImpl(ref.read(movieDataSourceProvider)),
);

final getMoviesProvider = Provider<GetMovies>(
  (ref) => GetMovies(ref.read(movieRepositoryProvider)),
);
```

## Contrato

- `presentation` no instancia manualmente repositorios/data sources: los resuelve vía estos providers (SC-004).
- El ViewModel lee `getMoviesProvider` (`ref.read`) para invocar el caso de uso.

---

# Contract: `HomeViewModel`

**File**: `lib/features/home/presentation/viewmodels/home_view_model.dart`

```dart
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, UIState<List<Movie>>>(HomeViewModel.new);

class HomeViewModel extends Notifier<UIState<List<Movie>>> {
  @override
  UIState<List<Movie>> build() => const UIState.success([]); // estado inicial vacío

  Future<void> loadMovies() async {
    state = const UIState.loading();
    final result = await ref.read(getMoviesProvider)();
    state = result.when(
      empty: () => const UIState.success([]),
      success: (movies) => UIState.success(movies),
      fail: (failure) => UIState.fail(failure),
    );
  }
}
```

## Contrato

- Expone `UIState<List<Movie>>`; muta a `loading` antes de la petición y a `success`/`fail` al resolver.
- Solo maneja entidades `Movie` (nunca `MovieModel`).
- La UI (`HomeScreen`) observa `homeViewModelProvider` y dispara `loadMovies()` desde el botón de verificación.
