# Data Model: Arquitectura Base (Clean Architecture Scaffold)

**Feature**: `001-arquitectura-base` | **Date**: 2026-07-01

Modela los tipos que atraviesan las capas y demuestran el cableado. Todos los tipos inmutables se generan con **Freezed**. La regla de dependencia apunta hacia adentro: `presentation → domain ← data`; `domain` no importa nada de las otras capas.

---

## Entidades de dominio (`domain/`)

### `Movie` (entidad, placeholder)
Ubicación: `lib/features/home/domain/entities/movie.dart`

| Campo   | Tipo     | Reglas |
|---------|----------|--------|
| `id`    | `int`    | Requerido, > 0, identidad de la película |
| `title` | `String` | Requerido, no vacío |

- Inmutable (Freezed). Se ampliará (poster, overview, rating…) en features reales.
- **No** conoce `MovieModel` ni ninguna clase de data/presentation.

### `Failure` (dominio)
Ubicación: `lib/core/error/failure.dart`

Unión sellada (Freezed) que representa fallos de dominio:

| Variante        | Campos            | Uso |
|-----------------|-------------------|-----|
| `serverFailure` | `String? message` | Error de origen de datos (mock/API) |
| `unexpected`    | `String? message` | Fallo no clasificado |

- Transportado por la variante `fail` de `Result<T>` y `UIState<T>`.

---

## Tipos genéricos compartidos (`core/`)

### `Result<T>` (contrato entre capas)
Ubicación: `lib/core/result/result.dart`

Unión sellada (Freezed) **producida por el repositorio**:

| Variante   | Campos           | Significado |
|------------|------------------|-------------|
| `empty`    | —                | Operación exitosa sin datos |
| `success`  | `T data`         | Datos disponibles |
| `fail`     | `Failure failure`| Error controlado |

- Genérico en `T` (para `home`: `Result<List<Movie>>`).
- Fluye repositorio → caso de uso → ViewModel.

### `UIState<T>` (estado de presentación)
Ubicación: `lib/core/state/ui_state.dart`

Clase sellada en **Dart puro (sin Freezed)** — clase madre `UIState<T>` con subclases `UILoading`/`UISuccess`/`UIFail`. Estado de cada ViewModel:

| Variante   | Campos            | Render UI |
|------------|-------------------|-----------|
| `loading`  | —                 | Indicador de carga |
| `success`  | `T data`          | Datos (o vacío) |
| `fail`     | `Failure failure` | Mensaje de error |

- Estado inicial recomendado: `UIState.loading()` o un `success` vacío antes de disparar la acción.
- Mapeo desde `Result<T>` en el ViewModel: `success→success`, `empty→success(vacío)`, `fail→fail`.

---

## Modelos de datos (`data/`)

### `MovieModel`
Ubicación: `lib/features/home/data/models/movie_model.dart`

| Campo   | Tipo     | Notas |
|---------|----------|-------|
| `id`    | `int`    | Corresponde a `id` de TMDB en el futuro |
| `title` | `String` | Corresponde a `title` de TMDB |

- **Confinado a la capa data**. Expone `Movie toEntity()` para el mapeo modelo→entidad.
- (Futuro) `factory MovieModel.fromJson(...)` cuando se integre TMDB. No requerido por el mock.

---

## Relaciones y flujo de datos

```text
MovieMockDataSource ──Future<List<MovieModel>>──► MovieRepositoryImpl
                                                        │  (model.toEntity())
                                                        ▼
                                          Result<List<Movie>>  (empty/success/fail)
                                                        │
                          GetMovies (usecase) ◄─────────┘  devuelve Result<List<Movie>>
                                     │
                          HomeViewModel (Notifier)
                                     │  mapea Result → UIState
                                     ▼
                          UIState<List<Movie>>  (loading/success/fail)  ──► HomeScreen
```

## Reglas de validación (derivadas de requisitos)

- **FR-003 / SC-003**: `domain/` sin imports a `data/` ni `presentation/`.
- **FR-006c / SC-004a**: `MovieModel` no importado fuera de `data/`; el ViewModel solo maneja `Movie`.
- **FR-005a**: `Result<T>` con exactamente tres variantes (empty/success/fail), generado por Freezed.
- **FR-004**: el data source devuelve 2-3 `MovieModel` tras `await Future` con latencia simulada.
