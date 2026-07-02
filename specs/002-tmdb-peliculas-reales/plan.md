# Implementation Plan: Consumo real de películas (TMDB)

**Branch**: `002-tmdb-peliculas-reales` | **Date**: 2026-07-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-tmdb-peliculas-reales/spec.md`

## Summary

Activar el consumo **real** de TMDB sobre la base de `001-arquitectura-base`. Se autentica con el **Read Access Token estático** leído de un archivo **`.env`** (flutter_dotenv). Se amplían las entidades (`Movie` con póster y rating; nueva `MovieDetail`), se definen los **4 casos de uso** (populares, top rated, detalle, búsqueda) con sus métodos en repositorio y data source, y la **pantalla principal** muestra el listado **Popular** con **scroll infinito**, pósters (cached_network_image), rating, y estados carga/éxito/vacío/error con reintento. Top Rated, Detalle y Búsqueda quedan cableados end-to-end (sin UI dedicada aún).

## Technical Context

**Language/Version**: Dart 3.10.7 / Flutter 3.38.6  
**Primary Dependencies (nuevas)**: `flutter_dotenv` (token desde `.env`), `cached_network_image` (pósters). Ya presentes: dio, retrofit, json_serializable, flutter_riverpod, freezed, equatable, fluro  
**Storage**: N/A (sin persistencia local; datos en memoria por sesión)  
**Testing**: `flutter_test` + `mocktail` (suite actualmente en `test_disabled/`)  
**Target Platform**: iOS y Android  
**Auth**: TMDB **Read Access Token (Bearer)** estático, header `Authorization: Bearer <token>`, token en `.env` (fuera de git). Sin `session_id`.  
**Performance Goals**: resultado (lista/error) < 3 s en red normal; scroll fluido al paginar  
**Constraints**: regla de dependencia Clean Architecture; modelo confinado a data; no reorganizar carpetas  
**Scale/Scope**: 1 feature con UI (Popular) + 3 operaciones cableadas; ~10-14 archivos nuevos/editados

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitución (`.specify/memory/constitution.md`) en estado **plantilla sin ratificar** → sin gates formales. **PASS**. Principios de facto respetados: separación de capas, casos de uso en domain, testabilidad, secretos fuera del código.

## Project Structure

### Documentation (this feature)

```text
specs/002-tmdb-peliculas-reales/
├── plan.md · research.md · data-model.md · quickstart.md
├── contracts/
│   ├── movie_service.md        # endpoints TMDB (retrofit)
│   └── use_cases.md            # casos de uso + repositorio + providers
└── tasks.md                    # (/speckit-tasks)
```

### Source Code (deltas sobre lib/)

```text
lib/
├── main.dart                         # + await dotenv.load() antes de runApp
├── core/
│   └── api/
│       ├── api_config.dart           # token desde dotenv + imageBaseUrl + posterSize
│       └── remote/dio_provider.dart  # header Bearer desde ApiConfig
└── features/home/
    ├── data/
    │   ├── datasources/
    │   │   ├── api/movie_service.dart          # getMovieDetail → MovieDetailModel
    │   │   ├── movie_data_source.dart          # + 4 métodos (ApiResponse)
    │   │   └── movie_data_source_remote.dart   # llamada real (quita mock)
    │   └── models/
    │       ├── movie_model.dart                # + posterPath, voteAverage
    │       ├── movie_response_model.dart       # + totalPages (hasMore)
    │       └── movie_detail_model.dart          # NUEVO (extends MovieDetail)
    ├── domain/
    │   ├── entities/
    │   │   ├── movie.dart                      # + posterPath, voteAverage
    │   │   └── movie_detail.dart               # NUEVO
    │   ├── repositories/movie_repository.dart  # + 4 métodos (entidades)
    │   └── usecases/
    │       ├── get_popular_movies.dart         # (page)
    │       ├── get_top_rated_movies.dart       # NUEVO
    │       ├── get_movie_detail.dart           # NUEVO
    │       └── search_movies.dart              # NUEVO
    └── presentation/
        ├── providers/home_providers.dart       # providers de los 4 casos de uso
        ├── viewmodels/
        │   ├── paged_movies.dart               # {items, page, hasMore, isLoadingMore}
        │   └── home_view_model.dart            # auto-load + paginación
        └── ui/
            ├── home_screen.dart                # ListView + scroll infinito + estados
            └── widgets/
                ├── movie_tile.dart             # póster + título + rating
                └── poster_image.dart           # NUEVO (cached_network_image + placeholder)
```

**Structure Decision**: Se reutiliza la estructura de `001` sin cambios de organización; solo se añaden entidades/modelos/casos de uso y se enriquece la UI de `home`. `MovieRepositoryRemote` devuelve entidades; el data source usa `ApiResponse` + retrofit real.

## Decisiones de detalle (puntos diferidos de clarify)

- **Rating**: se muestra con **un decimal** (p. ej. `8.5`).
- **Póster**: tamaño **`w342`**; URL `https://image.tmdb.org/t/p/w342{poster_path}`; placeholder si falta.
- **Home**: el listado Popular se **carga automáticamente al abrir** (reemplaza el botón "Verificar" del scaffold).
- **Paginación**: estado `PagedMovies` dentro de `UIState.success`; al acercarse al final se pide la siguiente página; `hasMore = page < totalPages`.

## Complexity Tracking

> No aplica — Constitution Check en PASS.
