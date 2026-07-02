# Data Model: Consumo real de películas (TMDB)

**Feature**: `002-tmdb-peliculas-reales` | **Date**: 2026-07-01

Amplía el modelo de `001`. Los modelos **extienden** sus entidades (LSP) y añaden `fromJson` (json_serializable). Regla de dependencia intacta: domain no importa data/presentation.

---

## Entidades de dominio (`domain/`)

### `Movie` (ampliada) — `domain/entities/movie.dart`
| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | `int` | Identidad |
| `title` | `String` | Requerido |
| `posterPath` | `String?` | Ruta relativa del póster (puede ser nula) |
| `voteAverage` | `double` | Calificación 0–10 |

- `Equatable` (props: los 4 campos).

### `MovieDetail` — `domain/entities/movie_detail.dart` (NUEVO)
| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | `int` | |
| `title` | `String` | |
| `posterPath` | `String?` | |
| `voteAverage` | `double` | |
| `overview` | `String` | Sinopsis |
| `releaseDate` | `String?` | Fecha de estreno (ISO) |
| `runtime` | `int?` | Duración en minutos |
| `genres` | `List<String>` | Nombres de géneros |

- `Equatable`.

---

## Modelos de datos (`data/models/`)

### `MovieModel extends Movie` — `movie_model.dart`
Añade `@JsonKey`:
- `poster_path` → `posterPath`
- `vote_average` → `voteAverage`
- `title`, `id` directos.
- `fromJson`/`toJson` generados.

### `MovieDetailModel extends MovieDetail` — `movie_detail_model.dart` (NUEVO)
Mapea `overview`, `release_date` → `releaseDate`, `runtime`, y `genres` (lista de objetos `{id,name}` → `List<String>` de nombres; se resuelve con un conversor o mapeo en `fromJson`).

### `MovieResponseModel` (Freezed) — `movie_response_model.dart`
| Campo | Tipo | Notas |
|-------|------|-------|
| `page` | `int` | Página actual |
| `results` | `List<MovieModel>` | Ítems |
| `totalPages` | `int` | `@JsonKey(name:'total_pages')`; para `hasMore` |

---

## Paginación de dominio

### `PageResult<T>` — `domain/entities/page_result.dart` (NUEVO)
| Campo | Tipo | Notas |
|-------|------|-------|
| `items` | `List<T>` | Ítems de la página |
| `page` | `int` | Página devuelta |
| `hasMore` | `bool` | `page < totalPages` |

- Lo devuelven el repositorio y los casos de uso de listado/búsqueda (no expone el modelo de respuesta a domain/presentation).

## Estado de presentación

### `PagedMovies` — `presentation/viewmodels/paged_movies.dart` (NUEVO)
| Campo | Tipo | Notas |
|-------|------|-------|
| `items` | `List<Movie>` | Acumulado de todas las páginas cargadas |
| `page` | `int` | Última página cargada |
| `hasMore` | `bool` | `page < totalPages` |
| `isLoadingMore` | `bool` | Cargando la siguiente página |
| `loadMoreError` | `bool` | Falló la carga de la siguiente página (reintento en footer) |

- Estado del `HomeViewModel`: `UIState<PagedMovies>` (loading inicial / success(PagedMovies) / fail(message)).

---

## Flujo de datos (listado Popular con paginación)

```text
MovieService.getPopularMovies(page)
   → MovieResponseModel (page, results: List<MovieModel>, totalPages)
   → MovieDataSourceRemote: ApiResponse<MovieResponseModel>
   → MovieRepositoryRemote: when(success → (List<Movie>, hasMore) ; error → throw)
   → GetPopularMovies(page) → devuelve entidades + info de paginación
   → HomeViewModel: acumula items, actualiza page/hasMore → UIState<PagedMovies>
   → HomeScreen: ListView (posters+título+rating) + footer loading/retry
```

## Reglas de validación

- `posterPath` nulo → placeholder visual (no romper layout).
- `hasMore` derivado de `page < totalPages`; no pedir más allá de la última página.
- Modelos confinados a data; ViewModel maneja solo `Movie`/`MovieDetail`.
- `voteAverage` se muestra con un decimal.
