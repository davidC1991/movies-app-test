# Research: Consumo real de películas (TMDB)

**Feature**: `002-tmdb-peliculas-reales` | **Date**: 2026-07-01

Sin marcadores `NEEDS CLARIFICATION` pendientes.

## Decisión 1: Autenticación con Read Access Token estático (Bearer)

- **Decision**: Autenticar los endpoints de lectura con el **API Read Access Token (v4)** de TMDB en el header `Authorization: Bearer <token>`.
- **Rationale**: Es estático (no expira), y los endpoints requeridos (`movie/popular`, `movie/top_rated`, `movie/{id}`, `search/movie`) son de lectura pública; no requieren `session_id`.
- **Alternatives considered**:
  - Flujo `session_id` (request_token → aprobación en navegador → session_id): descartado; el `request_token` expira a los 60 min y el `session_id` solo sirve para acciones de usuario (rating/watchlist) que el ejercicio no pide.
  - API Key v3 por query `?api_key=`: válido, pero el Bearer v4 es el esquema recomendado actual.

## Decisión 2: Token en `.env` con flutter_dotenv

- **Decision**: Guardar el token en un archivo **`.env`** (no versionado) y leerlo con **`flutter_dotenv`** al arrancar (`await dotenv.load()` en `main`).
- **Rationale**: Mantiene el secreto fuera del código y de git; el token es estático, así que `.env` es apropiado (no hay expiración de 60 min).
- **Setup**: declarar `.env` en `assets` del `pubspec.yaml`, añadir `.env` al `.gitignore`, y crear `.env.example` como plantilla.
- **Alternatives considered**: `--dart-define` (válido, pero el usuario prefiere `.env`); constante en código (inseguro).
- **Versión**: `flutter_dotenv: ^5.1.0`.

## Decisión 3: Imágenes de póster con cached_network_image

- **Decision**: Componer la URL del póster con base `https://image.tmdb.org/t/p/w342` + `poster_path`, y renderizar con **`cached_network_image`** (placeholder mientras carga, fallback si falla o si `poster_path` es nulo).
- **Rationale**: Cacheo en disco/memoria, placeholders y manejo de error listos; evita reventar el layout con imágenes faltantes.
- **Versión**: `cached_network_image: ^3.4.1`. Tamaño `w342` equilibra calidad/peso para lista.

## Decisión 4: Paginación (scroll infinito) con estado `PagedMovies`

- **Decision**: Modelar el estado de éxito del listado como `UIState<PagedMovies>`, donde `PagedMovies { List<Movie> items, int page, bool hasMore, bool isLoadingMore, bool loadMoreError }`. El `HomeViewModel` carga la página 1 al construirse; un `ScrollController` detecta proximidad al final y dispara `loadMore()` que pide `page+1` y **anexa** los resultados.
- **Rationale**: Mantiene la clase sellada `UIState` sin cambios (loading/success/fail) y encapsula la paginación en el dato de éxito. `hasMore = page < total_pages` (de la respuesta TMDB).
- **Alternatives considered**: añadir una variante `UILoadingMore` a `UIState` (más ruido en el tipo genérico); usar un paquete de paginación (innecesario para el alcance).

## Decisión 5: Casos de uso por operación

- **Decision**: Un caso de uso por operación: `GetPopularMovies(page)`, `GetTopRatedMovies(page)`, `GetMovieDetail(id)`, `SearchMovies(query, page)`. Cada uno delega en el `MovieRepository` (método homónimo). El `MovieRepositoryRemote` usa `ApiResponse.when` y devuelve entidades (o lanza en error).
- **Rationale**: Cumple FR-002; desacopla presentación de data; habilita las features siguientes.

## Decisión 6: Entidades `Movie` y `MovieDetail`

- **Decision**: `Movie` (lista): `id`, `title`, `posterPath`, `voteAverage`. `MovieDetail`: extiende la información con `overview`, `releaseDate`, `runtime`, `genres`. Modelos `MovieModel`/`MovieDetailModel` extienden sus entidades (LSP) y añaden `fromJson` (json_serializable con `@JsonKey` para `poster_path`, `vote_average`, etc.).
- **Rationale**: Consistente con el patrón de `001` (modelo extiende entidad). El detalle es entidad aparte porque la respuesta de `movie/{id}` trae más campos.

## Decisión 7: Activar la llamada real (quitar mock)

- **Decision**: `MovieDataSourceRemote` deja de simular y llama a `MovieService` real vía `executeApiCall(...)`, mapeando `MovieResponseModel.results`.
- **Rationale**: Objetivo de la feature. Ante 401 (token inválido) o sin red, el mixin produce `ErrorApiResponse` → el repositorio lanza → el ViewModel muestra `UIFail` con reintento.

---

## Dependencias resultantes (pubspec)

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
  cached_network_image: ^3.4.1

flutter:
  assets:
    - .env
```

`.gitignore`: añadir `.env`. Crear `.env.example` con `TMDB_TOKEN=`.
