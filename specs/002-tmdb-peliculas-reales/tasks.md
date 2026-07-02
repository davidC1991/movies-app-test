---
description: "Task list for Consumo real de películas (TMDB)"
---

# Tasks: Consumo real de películas (TMDB)

**Input**: Design documents from `/specs/002-tmdb-peliculas-reales/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: NO incluidos (la suite unitaria está desactivada en `test_disabled/` por priorización). Se pueden reactivar/añadir después.

**Organization**: Tareas agrupadas por user story para implementación y prueba independientes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede correr en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: US1 / US2 / US3
- Rutas relativas a la raíz del repo

## Path Conventions

Mobile app (Flutter). Código en `lib/`. Reutiliza la estructura de `001-arquitectura-base`.

---

## Phase 1: Setup

**Purpose**: Dependencias, archivo `.env` y bootstrap

- [X] T001 Añadir dependencias en `pubspec.yaml` (`flutter_dotenv: ^5.1.0`, `cached_network_image: ^3.4.1`) y ejecutar `flutter pub get`
- [X] T002 [P] Declarar el asset `.env` en `pubspec.yaml` (`flutter: assets: - .env`), añadir `.env` a `.gitignore` y crear `.env.example` con `TMDB_TOKEN=`
- [X] T003 Cargar dotenv en `lib/main.dart` (`await dotenv.load(fileName: '.env')` antes de `runApp`, con `WidgetsFlutterBinding.ensureInitialized()`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Config de red, entidades, modelos y generación — bloquean todas las user stories

**⚠️ CRITICAL**: Completar antes de las user stories.

- [X] T004 [P] Ampliar `lib/core/api/api_config.dart`: leer `tmdbToken` de `dotenv.env['TMDB_TOKEN']`, añadir `imageBaseUrl` (`https://image.tmdb.org/t/p`), `posterSize` (`w342`) y helper `posterUrl(String? path)`
- [X] T005 Actualizar `lib/core/api/remote/dio_provider.dart` para tomar el token de `ApiConfig` (header `Authorization: Bearer`)
- [X] T006 [P] Ampliar entidad `Movie` en `lib/features/home/domain/entities/movie.dart` con `posterPath` (String?) y `voteAverage` (double); actualizar `props` de Equatable
- [X] T007 [P] Crear entidad `MovieDetail` en `lib/features/home/domain/entities/movie_detail.dart` (id, title, posterPath, voteAverage, overview, releaseDate, runtime, genres) con Equatable
- [X] T008 [P] Crear `PageResult<T>` en `lib/features/home/domain/entities/page_result.dart` (items, page, hasMore)
- [X] T009 Ampliar `MovieModel` en `lib/features/home/data/models/movie_model.dart` con `posterPath` (`@JsonKey('poster_path')`) y `voteAverage` (`@JsonKey('vote_average')`) (depende de T006)
- [X] T010 Crear `MovieDetailModel extends MovieDetail` en `lib/features/home/data/models/movie_detail_model.dart` con `fromJson` (mapea `release_date`, `runtime`, `overview`, y `genres` [{id,name}] → List<String>) (depende de T007)
- [X] T011 Ampliar `MovieResponseModel` en `lib/features/home/data/models/movie_response_model.dart` con `totalPages` (`@JsonKey('total_pages')`)
- [X] T012 Actualizar `MovieService` en `lib/features/home/data/datasources/api/movie_service.dart`: `getMovieDetail` retorna `Future<MovieDetailModel>` (depende de T010)
- [X] T013 Ejecutar `dart run build_runner build --delete-conflicting-outputs` para regenerar `*.g.dart` de modelos y servicio (depende de T009, T010, T011, T012)

**Checkpoint**: modelos/entidades/servicio compilan; Dio manda el Bearer token desde `.env`.

---

## Phase 3: User Story 1 - Ver películas reales en el listado (Priority: P1) 🎯 MVP

**Goal**: La pantalla principal carga y muestra el listado **Popular** real de TMDB (póster + título + rating) con **scroll infinito** y estados carga/éxito/vacío.

**Independent Test**: Con el token en `.env`, abrir la app y ver películas reales; al hacer scroll al final se cargan más.

- [X] T014 [US1] Definir `MovieDataSource` (abstracto) con `getPopular({int page})` e implementar en `MovieDataSourceRemote` la llamada real (`executeApiCall(service.getPopularMovies(page: page))`), quitando el mock, en `lib/features/home/data/datasources/movie_data_source.dart` y `movie_data_source_remote.dart`
- [X] T015 [US1] Definir `MovieRepository.getPopular({int page}) → Future<PageResult<Movie>>` e implementar en `MovieRepositoryRemote` (`when` → `PageResult(items, page, hasMore = page < totalPages)`; error → throw) en `movie_repository.dart` y `movie_repository_remote.dart` (depende de T014, T008)
- [X] T016 [US1] Crear caso de uso `GetPopularMovies` en `lib/features/home/domain/usecases/get_popular_movies.dart` (`call({int page})` → repo.getPopular) (depende de T015)
- [X] T017 [P] [US1] Crear estado `PagedMovies` en `lib/features/home/presentation/viewmodels/paged_movies.dart` (items, page, hasMore, isLoadingMore, loadMoreError) con `copyWith`
- [X] T018 [US1] Actualizar `lib/features/home/presentation/providers/home_providers.dart`: cadena `dio → movieService → movieDataSource → movieRepository → getPopularMovies` + `homeViewModelProvider` (depende de T016)
- [X] T019 [US1] Crear `HomeViewModel` (`Notifier<UIState<PagedMovies>>`) en `lib/features/home/presentation/viewmodels/home_view_model.dart`: `build()` auto-carga página 1 (`UILoading`→`UISuccess`/`UIFail`), `loadMore()` anexa página siguiente (isLoadingMore/loadMoreError), `retry()` (depende de T017, T018)
- [X] T020 [P] [US1] Crear widget `PosterImage` en `lib/features/home/presentation/ui/widgets/poster_image.dart` (cached_network_image con `ApiConfig.posterUrl`, placeholder y fallback si `posterPath` es nulo/falla)
- [X] T021 [US1] Actualizar `MovieTile` en `lib/features/home/presentation/ui/widgets/movie_tile.dart` para mostrar `PosterImage` + título + rating (1 decimal) (depende de T020, T006)
- [X] T022 [US1] Reescribir `HomeScreen` en `lib/features/home/presentation/ui/home_screen.dart`: `ListView.builder` + `ScrollController` (dispara `loadMore` cerca del final), estados loading/success/vacío/error, footer de carga, y **quitar el botón "Verificar"** (carga automática) (depende de T019, T021)

**Checkpoint**: `flutter run` (con `.env`) muestra el listado Popular real con scroll infinito. **MVP entregable.**

---

## Phase 4: User Story 2 - Manejo de errores y reintento (Priority: P2)

**Goal**: Ante fallos (sin red, token inválido, error de servidor) se muestra un mensaje claro con opción de reintentar, tanto en la carga inicial como al paginar.

**Independent Test**: Ejecutar sin `.env`/red y confirmar mensaje de error + botón Reintentar; provocar fallo al paginar y reintentar sin perder lo cargado.

- [X] T023 [US2] Mapear `ErrorApiResponse.httpErrorMessage` a un mensaje legible en `UIFail` (carga inicial) y exponer `retry()` en la UI de error, en `home_view_model.dart` y `home_screen.dart`
- [X] T024 [US2] Manejar error de paginación: en `loadMore` marcar `loadMoreError` sin descartar items; mostrar en el footer un botón "Reintentar" que reintenta la página fallida, en `home_view_model.dart` y `home_screen.dart`

**Checkpoint**: errores legibles y recuperables en ambos flujos.

---

## Phase 5: User Story 3 - Casos de uso restantes cableados (Priority: P2)

**Goal**: Dejar Top Rated, Detalle y Búsqueda disponibles como casos de uso end-to-end (sin UI dedicada) para features futuras.

**Independent Test**: Verificar que existen los 3 casos de uso, cada uno con su método en repositorio y data source consumiendo el endpoint correcto.

- [X] T025 [US3] Añadir a `MovieDataSource`/`MovieDataSourceRemote`: `getTopRated({page})`, `getDetail(id)`, `search(query,{page})` (vía `MovieService`, `executeApiCall`)
- [X] T026 [US3] Añadir a `MovieRepository`/`MovieRepositoryRemote`: `getTopRated`→`PageResult<Movie>`, `getDetail`→`MovieDetail`, `search`→`PageResult<Movie>` (depende de T025)
- [X] T027 [P] [US3] Crear casos de uso `GetTopRatedMovies`, `GetMovieDetail`, `SearchMovies` en `lib/features/home/domain/usecases/` (depende de T026)
- [X] T028 [US3] Registrar providers de los 3 casos de uso en `home_providers.dart` (depende de T027)

**Checkpoint**: los 4 casos de uso existen e invocables desde presentación.

---

## Phase 6: Polish & Cross-Cutting

- [X] T029 [P] Ejecutar `flutter analyze` y resolver errores/warnings nuevos
- [X] T030 [P] Verificar reglas arquitectónicas (grep de `quickstart.md`): domain sin imports a data/presentation; modelos confinados a data
- [X] T031 Verificar en dispositivo/emulador con el token real: listado Popular carga, scroll infinito anexa páginas, estado de error con reintento
- [X] T032 [P] Actualizar `README.md` (cómo configurar `.env`/token, cómo correr) y nota en el ADR sobre la integración real

---

## Dependencies & Execution Order

- **Setup (P1)** → **Foundational (P2)** bloquea todo.
- **US1 (P3)**: depende de Foundational. Es el MVP.
- **US2 (P4)**: depende de US1 (refina sus estados de error/paginación).
- **US3 (P5)**: depende de Foundational; independiente de US1/US2 en la UI (solo añade casos de uso). Puede solaparse con US1 tras Foundational.
- **Polish (P6)**: al final.

### Ruta crítica (US1)
```
T014 → T015 → T016 → T018 → T019 → T022
T017 ─┘(estado)         T020 → T021 ─┘
```

---

## Parallel Execution Examples

**Foundational**: `T006 (Movie) | T007 (MovieDetail) | T008 (PageResult)` → luego modelos T009/T010/T011 → `T013 build_runner`.
**US1**: `T017 (PagedMovies) | T020 (PosterImage)` en paralelo mientras avanza la cadena data/domain.
**Polish**: `T029 (analyze) | T030 (reglas) | T032 (README)`.

---

## Implementation Strategy

### MVP First
1. **Phase 1 + 2** (setup + fundacional).
2. **Phase 3 (US1)** → validar: `flutter run` con `.env`, listado Popular real + scroll. **Entregable.**
3. **Phase 4 (US2)** robustez de errores.
4. **Phase 5 (US3)** casos de uso restantes.
5. **Phase 6** cierre.

### Total de tareas: 32

| Fase | Tareas |
|------|--------|
| Phase 1 — Setup | T001–T003 (3) |
| Phase 2 — Foundational | T004–T013 (10) |
| Phase 3 — US1 (MVP) | T014–T022 (9) |
| Phase 4 — US2 | T023–T024 (2) |
| Phase 5 — US3 | T025–T028 (4) |
| Phase 6 — Polish | T029–T032 (4) |
