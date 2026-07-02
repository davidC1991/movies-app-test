# Contract: `MovieRepository`

**Layer**: domain (abstracción) — implementada en data  
**File (domain)**: `lib/features/home/domain/repositories/movie_repository.dart`  
**File (data impl)**: `lib/features/home/data/repositories/movie_repository_impl.dart`

## Interfaz (domain)

```dart
abstract interface class MovieRepository {
  /// Obtiene el listado de películas.
  /// Devuelve Result<List<Movie>> con variantes empty / success / fail.
  Future<Result<List<Movie>>> getMovies();
}
```

## Contrato de comportamiento

| Condición                                   | Retorno esperado |
|---------------------------------------------|------------------|
| El data source devuelve ≥ 1 `MovieModel`    | `Result.success(List<Movie>)` (modelos ya mapeados a entidades) |
| El data source devuelve lista vacía         | `Result.empty()` |
| El data source lanza / falla                | `Result.fail(Failure.serverFailure(...))` |
| Error inesperado no controlado              | `Result.fail(Failure.unexpected(...))` |

## Reglas

- La implementación es el **único punto de conversión** `MovieModel → Movie` (`model.toEntity()`).
- No propaga excepciones hacia domain/presentation: todo fallo se envuelve en `Result.fail`.
- No expone `MovieModel` en su firma (confinamiento a la capa data).

## Pruebas asociadas

`test/features/home/data/movie_repository_impl_test.dart`:
- Con data source que devuelve modelos → `success` con entidades mapeadas correctamente.
- Con data source que devuelve vacío → `empty`.
- Con data source que lanza excepción → `fail`.
