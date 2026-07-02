# Implementation Plan: Cobertura de pruebas unitarias e integración

**Branch**: `004-cobertura-tests` | **Date**: 2026-07-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/004-cobertura-tests/spec.md`

## Summary

Estandarizar la estrategia de pruebas de la app en **mockito** (retirando mocktail) con pruebas unitarias en **las tres capas** de la Clean Architecture y pruebas de integración E2E:

- **Domain**: `MovieUseCases` (delegación al repositorio), `MovieGenre.fromId`.
- **Data**: `fromJson` de los modelos (+`GenresConverter`, `backdrop_path`), `MovieRepositoryRemote` (mapeo `ApiResponse` → `PageResult`/`MovieDetail`, `hasMore`, lanzar en error), `MovieDataSourceRemote` (envoltura de `MovieService`) y `ApiConfig`.
- **Presentation**: ViewModels (catálogo, búsqueda, detalle) aseverando **transiciones de estado** (`UILoading → UISuccess/UIFail`) con `container.listen(..., fireImmediately: true)`, y los estados `PagedMoviesState`/`CatalogState`.
- **Integración**: driver de Flutter (`integration_test`) sobre los recorridos reales (catálogo, búsqueda, listado→detalle→volver, cargar más al hacer scroll).

Se mockea en la **frontera de cada capa** (data source para el repo; service para el data source; repository para usecases/ViewModels). Los **widget tests actuales se eliminan**; sus flujos pasan a integración. Objetivo de cobertura de líneas **≥ 80%** en `domain` + `data` + `presentation`, con reporte `flutter test --coverage`.

## Technical Context

**Language/Version**: Dart 3.10.7 / Flutter 3.38.6
**Primary Dependencies (test)**: `mockito` (dobles + codegen con `build_runner`), `integration_test` (SDK, driver de Flutter), `flutter_test`. Se **retira** `mocktail`.
**Storage**: N/A (datos simulados en memoria; sin red real)
**Testing**: `flutter test` (unit) · `flutter test integration_test` / `flutter drive` (integración) · `flutter test --coverage` (reporte)
**Target Platform**: iOS 15+ / Android (integración corre en emulador/simulador)
**Project Type**: Mobile app (Clean Architecture + MVVM); esta feature toca solo la carpeta `test/`, `integration_test/`, `test_driver/` y `pubspec.yaml`
**Performance Goals**: suite unitaria rápida (< pocos segundos), sin esperas arbitrarias; debounce con reloj controlado
**Constraints**: sin red real ni credenciales; determinismo; aislamiento por prueba; cobertura ≥ 80% en `domain` + `data` + `presentation`
**Scale/Scope**: unitarias en las **3 capas** (domain: usecases/enum; data: modelos/repositorio/datasource/config; presentation: 3 ViewModels + estados) + 1 suite de integración de los flujos principales; dominio Películas

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

La constitución (`.specify/memory/constitution.md`) está sin personalizar (plantilla) → sin gates formales. Gates de facto aplicables:

- **No romper capas**: las pruebas mockean en la **frontera del repositorio** (`MovieRepository`) y usan la DI real por encima; no se acopla el test a `data`/red.
- **MVVM verificable**: se asevera `UIState<T>` emitido por los `Notifier` (patrón `container.listen` con emisión inmediata) — coherente con la arquitectura.
- **Determinismo y aislamiento**: cada test recrea su `ProviderContainer`/mocks; el debounce se prueba con control de reloj (no `sleep`).

Sin violaciones → **Complexity Tracking** vacío.

## Project Structure

### Documentation (this feature)

```text
specs/004-cobertura-tests/
├── plan.md              # Este archivo
├── spec.md              # Especificación (con Clarifications)
├── research.md          # Fase 0 (decisiones de tooling)
├── data-model.md        # Fase 1 (fixtures y dobles de prueba)
├── quickstart.md        # Fase 1 (cómo correr unit/integración/cobertura)
├── contracts/           # Fase 1 (contrato de aserción de transiciones de estado)
├── checklists/
│   └── requirements.md
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
pubspec.yaml                         # + mockito, + integration_test; - mocktail

test/
├── fixtures/
│   ├── movie_fixtures.dart          # [NUEVO] Movie/MovieDetail/PageResult de ejemplo
│   └── json_fixtures.dart           # [NUEVO] JSON crudo de TMDB para fromJson
├── helpers/
│   ├── mocks.dart                   # [NUEVO] @GenerateNiceMocks de Repository/DataSource/Service
│   ├── mocks.mocks.dart             # [GENERADO] por build_runner
│   └── provider_test_utils.dart     # [NUEVO] ProviderContainer con overrides + captura de estados
├── unit/
│   ├── domain/
│   │   ├── movie_use_cases_test.dart      # [NUEVO] delegación al repositorio
│   │   └── movie_genre_test.dart          # [NUEVO] fromId conocido / desconocido
│   ├── data/
│   │   ├── movie_model_test.dart          # [NUEVO] fromJson MovieModel/MovieResponseModel
│   │   ├── movie_detail_model_test.dart   # [NUEVO] fromJson + GenresConverter + backdrop_path
│   │   ├── movie_repository_remote_test.dart # [NUEVO] ApiResponse→entidad, hasMore, throw
│   │   ├── movie_data_source_remote_test.dart # [NUEVO] envoltura de MovieService
│   │   └── api_config_test.dart           # [NUEVO] posterUrl/backdropUrl (null/empty)
│   └── presentation/
│       ├── catalog_view_model_test.dart   # [REESCRITO] mockito + container.listen
│       ├── search_view_model_test.dart    # [REESCRITO]
│       ├── movie_detail_view_model_test.dart # [REESCRITO]
│       └── paged_movies_state_test.dart   # [NUEVO] fromPage/appendPage/startLoadingMore/failLoadingMore
└── widget/                          # [ELIMINADO] (4 archivos → cubiertos por integración)

integration_test/
└── app_test.dart                    # [NUEVO] flujos E2E con datos simulados

test_driver/
└── integration_test.dart            # [NUEVO] runner para `flutter drive`
```

**Structure Decision**: tests unitarios organizados **por capa** (`unit/domain`, `unit/data`, `unit/presentation`). Los dobles se generan en `test/helpers/mocks.dart` con una sola declaración `@GenerateNiceMocks([MockSpec<MovieRepository>(), MockSpec<MovieDataSource>(), MockSpec<MovieService>()])`. `provider_test_utils.dart` centraliza el `ProviderContainer` con `movieUseCasesProvider` sobrescrito por `MovieUseCases(mockRepository)` y la captura de la secuencia de estados.

## Phase 0 — Research (decisiones de tooling)

Salida en `research.md`. Decisiones clave:

1. **Dónde mockear (frontera de cada capa)**: para los **ViewModels** y **usecases** se mockea `MovieRepository` (sobrescribiendo `movieUseCasesProvider` con `MovieUseCases(mockRepository)`); para el **repositorio** se mockea `MovieDataSource`; para el **data source** se mockea `MovieService` (retrofit). Los **modelos**, `MovieGenre` y `ApiConfig` se prueban directamente (sin mocks). Cubre el pedido "mockear repository/providers" y además data/domain.
2. **mockito con codegen**: `@GenerateNiceMocks([MockSpec<MovieRepository>(), MockSpec<MovieDataSource>(), MockSpec<MovieService>()])` en `test/helpers/mocks.dart`; `dart run build_runner build --delete-conflicting-outputs` genera `mocks.mocks.dart`. `NiceMock` evita fallos por métodos no stubbeados.
3. **Aserción de transiciones de estado**: `container.listen(provider, (prev, next) {...}, fireImmediately: true)` capturando cada `UIState` en una lista; se asevera la secuencia (`UILoading` → `UISuccess`/`UIFail`) y que el camino feliz **no** emite `UIFail`. Es la traducción del ejemplo `fetchCifsBco` a este proyecto (que expone `UIState<T>` directo, no un objeto de estado con sub-campos).
4. **Determinismo del debounce**: el debounce vive en el widget `DebouncedSearchBar`; su prueba (ahora en integración/o unit de widget con `tester.pump(Duration)`) usa el reloj del `WidgetTester`. Los tests unitarios de `SearchViewModel` no dependen del debounce (la orquestación no lo incluye), así que son deterministas sin control de reloj.
5. **Integración con el driver de Flutter**: `integration_test` + `IntegrationTestWidgetsFlutterBinding`; se levanta la app envuelta en `ProviderScope(overrides: [...])` con el repositorio simulado devolviendo fixtures. `test_driver/integration_test.dart` permite `flutter drive`. Ejecutable también con `flutter test integration_test`.
6. **Cobertura**: `flutter test --coverage` → `coverage/lcov.info`; se verifica ≥ 80% en `lib/features/home/{domain,data,presentation}` y `lib/core/api`. (Opcional `genhtml` para reporte visual, informativo.)
7. **Retiro de mocktail**: se elimina la dependencia y no queda ningún `import 'package:mocktail/...'`.

## Phase 1 — Design (contratos y fixtures)

- **`data-model.md`**: catálogo de **fixtures** (listas de `Movie`, `MovieDetail`, `PageResult<Movie>` con y sin más páginas) y el **doble** `MockMovieRepository` (comportamientos: éxito, vacío, error/`throw`).
- **`contracts/`**: contrato de la utilidad de aserción de estados (entrada: provider + acciones; salida: lista de `UIState` observados) y la matriz de transiciones esperadas por ViewModel.
- **`quickstart.md`**: comandos para generar mocks (`build_runner`), correr unitarias, integración (`flutter test integration_test` / `flutter drive`) y cobertura (`flutter test --coverage`).

## Matriz de pruebas unitarias por capa

### Presentation (transiciones de estado con `container.listen`)

| ViewModel | Transición feliz | Transición error | Reglas de negocio cubiertas |
|-----------|------------------|------------------|-----------------------------|
| `CatalogViewModel` | `UILoading → UISuccess(CatalogState)` | `UILoading → UIFail` | paginar por categoría, no paginar sin más páginas, no re-lanzar tras `loadMoreError` |
| `SearchViewModel` | `UILoading → UISuccess(PagedMoviesState)` | `UILoading → UIFail` | término vacío = sin búsqueda, sin resultados, restaurar al `clear`, prevalece último término |
| `MovieDetailViewModel` | `UILoading → UISuccess(MovieDetail)` | `UILoading → UIFail` | reintento tras error |
| `PagedMoviesState` | — | — | `fromPage`, `appendPage`, `startLoadingMore`, `failLoadingMore` |

### Domain (mock `MovieRepository`)

| Objeto | Qué se verifica |
|--------|-----------------|
| `MovieUseCases` | delega cada operación al repositorio con los mismos parámetros y devuelve su resultado |
| `MovieGenre.fromId` | id conocido → género correcto; id desconocido → `unknown` |

### Data (mock `MovieDataSource` / `MovieService`)

| Objeto | Qué se verifica |
|--------|-----------------|
| `MovieModel` / `MovieResponseModel` | `fromJson` mapea campos snake_case; wrapper con `results`/`total_pages` |
| `MovieDetailModel` | `fromJson` + `GenresConverter` (`[{id,name}]` → `List<MovieGenre>`) + `backdrop_path` |
| `MovieRepositoryRemote` | `ApiResponse` success → `PageResult`/`MovieDetail`; `hasMore = page < totalPages`; empty/error → **lanza** |
| `MovieDataSourceRemote` | envuelve `MovieService` con `executeApiCall`; traduce éxito/`DioException` |
| `ApiConfig` | `posterUrl`/`backdropUrl` construyen la URL; `null`/vacío → `null` |

## Trabajo restante (resumen)

1. `pubspec.yaml`: +`mockito`, +`integration_test`; −`mocktail`.
2. `test/helpers/mocks.dart` (Repository/DataSource/Service) + generación con build_runner.
3. `test/fixtures/` (entidades + JSON crudo) y `test/helpers/provider_test_utils.dart`.
4. **Domain**: `movie_use_cases_test`, `movie_genre_test`.
5. **Data**: `movie_model_test`, `movie_detail_model_test`, `movie_repository_remote_test`, `movie_data_source_remote_test`, `api_config_test`.
6. **Presentation**: reescribir las 3 unitarias de ViewModel con mockito + `container.listen(fireImmediately: true)` + `paged_movies_state_test`.
7. Eliminar `test/widget/` (4 archivos).
8. `integration_test/app_test.dart` + `test_driver/integration_test.dart` (flujos E2E con fixtures).
9. Reporte de cobertura y verificación ≥ 80% en domain + data + presentation.

## Complexity Tracking

> Sin violaciones de constitución que justificar.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
