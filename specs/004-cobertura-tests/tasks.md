---
description: "Task list — Cobertura de pruebas unitarias e integración"
---

# Tasks: Cobertura de pruebas unitarias e integración

**Input**: Design documents from `/specs/004-cobertura-tests/`
**Prerequisites**: plan.md (required), spec.md (required)

**Tests**: Esta feature ES la suite de pruebas; todas las tareas producen tests o su infraestructura.

**Organization**: Tareas agrupadas por user story. La cobertura abarca las 3 capas (domain, data, presentation) + integración.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede correr en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: US1 / US2 / US3
- Rutas de archivo exactas en cada descripción

## Convenciones OBLIGATORIAS

- **mockito** para todos los dobles (codegen con `@GenerateNiceMocks` + build_runner). **Sin mocktail** en el proyecto.
- Los tests de ViewModel aseveran transiciones de `UIState` con `container.listen(provider, (prev, next) {…}, fireImmediately: true)`.
- Se mockea en la **frontera de cada capa**: `MovieRepository` (ViewModels/usecases), `MovieDataSource` (repositorio), `MovieService` (data source). Modelos, `MovieGenre` y `ApiConfig` se prueban directamente.
- Sin red real ni credenciales; determinismo; aislamiento por prueba (ProviderContainer/mocks recreados).

---

## Phase 1: Setup

**Purpose**: Dependencias de test y limpieza de la estrategia anterior.

- [X] T001 Editar `pubspec.yaml`: agregar `mockito` y `integration_test` (sdk: flutter) en dev_dependencies; **eliminar** `mocktail`
- [X] T002 Ejecutar `flutter pub get` y verificar resolución de dependencias
- [X] T003 Eliminar `test/widget/` (los 4 widget tests; sus flujos pasan a integración)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Mocks, fixtures y utilidades que necesitan TODAS las user stories.

**⚠️ CRITICAL**: Ninguna user story puede empezar hasta completar esta fase.

- [X] T004 Crear `test/helpers/mocks.dart` con `@GenerateNiceMocks([MockSpec<MovieRepository>(), MockSpec<MovieDataSource>(), MockSpec<MovieService>()])`
- [X] T005 Ejecutar `dart run build_runner build --delete-conflicting-outputs` para generar `test/helpers/mocks.mocks.dart`
- [X] T006 [P] Crear `test/fixtures/movie_fixtures.dart` (Movie/MovieDetail/PageResult de ejemplo, con y sin más páginas)
- [X] T007 [P] Crear `test/fixtures/json_fixtures.dart` (JSON crudo de TMDB para popular/top_rated/detail/search)
- [X] T008 Crear `test/helpers/provider_test_utils.dart`: builder de `ProviderContainer` con `movieUseCasesProvider` sobrescrito por `MovieUseCases(mockRepository)` + utilidad que captura la secuencia de `UIState` emitidos (depende de T005)

**Checkpoint**: Infraestructura de test lista.

---

## Phase 3: User Story 1 - Transiciones de estado de los ViewModels (Priority: P1) 🎯 MVP

**Goal**: Cada ViewModel emite la secuencia correcta (carga → éxito y carga → error) ante datos/errores simulados, observada con `container.listen(fireImmediately: true)`.

**Independent Test**: Ejecutar los tests de presentación y ver que, para cada ViewModel, se observa `UILoading` seguido de `UISuccess` (con datos simulados) o `UIFail`, y que el camino feliz nunca emite `UIFail`.

- [X] T009 [P] [US1] `test/unit/presentation/catalog_view_model_test.dart`: transición `UILoading → UISuccess(CatalogState)` y `→ UIFail` con `container.listen(..., fireImmediately: true)` (mock `MovieRepository`)
- [X] T010 [P] [US1] `test/unit/presentation/search_view_model_test.dart`: transiciones éxito/error observando el provider
- [X] T011 [P] [US1] `test/unit/presentation/movie_detail_view_model_test.dart`: transiciones éxito/error (familia por id)

**Checkpoint**: Las transiciones de estado quedan verificadas (MVP del pedido).

---

## Phase 4: User Story 2 - Cobertura unitaria por capa (Priority: P1)

**Goal**: Cubrir las reglas de negocio de presentación y las capas de dominio y datos con pruebas unitarias.

**Independent Test**: Ejecutar la suite unitaria y comprobar casos de paginación/búsqueda/detalle, delegación de casos de uso, resolución de géneros, `fromJson` de modelos, mapeo del repositorio y construcción de URLs.

### Presentation (reglas de negocio + estados)

- [X] T012 [US2] Ampliar `test/unit/presentation/catalog_view_model_test.dart`: paginar por categoría, no paginar sin más páginas, no re-lanzar tras `loadMoreError` (depende de T009)
- [X] T013 [US2] Ampliar `test/unit/presentation/search_view_model_test.dart`: término vacío = sin búsqueda, sin resultados, restaurar al `clear`, prevalece el último término (depende de T010)
- [X] T014 [US2] Ampliar `test/unit/presentation/movie_detail_view_model_test.dart`: reintento tras error (depende de T011)
- [X] T015 [P] [US2] `test/unit/presentation/paged_movies_state_test.dart`: `fromPage`/`appendPage`/`startLoadingMore`/`failLoadingMore`

### Domain (mock `MovieRepository`)

- [X] T016 [P] [US2] `test/unit/domain/movie_use_cases_test.dart`: cada operación delega en el repositorio con los mismos parámetros y devuelve su resultado
- [X] T017 [P] [US2] `test/unit/domain/movie_genre_test.dart`: `MovieGenre.fromId` con id conocido y desconocido (→ `unknown`)

### Data (mock `MovieDataSource` / `MovieService`, o prueba directa)

- [X] T018 [P] [US2] `test/unit/data/movie_model_test.dart`: `fromJson` de `MovieModel` y `MovieResponseModel` (results/total_pages)
- [X] T019 [P] [US2] `test/unit/data/movie_detail_model_test.dart`: `fromJson` + `GenresConverter` ([{id,name}]→List<MovieGenre>) + `backdrop_path`
- [X] T020 [P] [US2] `test/unit/data/movie_repository_remote_test.dart`: `ApiResponse` success → `PageResult`/`MovieDetail`; `hasMore = page < totalPages`; empty/error → lanza (mock `MovieDataSource`)
- [X] T021 [P] [US2] `test/unit/data/movie_data_source_remote_test.dart`: envuelve `MovieService`; traduce éxito y `DioException` (mock `MovieService`)
- [X] T022 [P] [US2] `test/unit/data/api_config_test.dart`: `posterUrl`/`backdropUrl` construyen la URL; `null`/vacío → `null`

**Checkpoint**: Las 3 capas tienen pruebas unitarias propias.

---

## Phase 5: User Story 3 - Pruebas de integración (Priority: P2)

**Goal**: Ejercitar la app real (driver de Flutter) en los recorridos principales con datos simulados.

**Independent Test**: Lanzar la app de integración con el repositorio simulado y recorrer: catálogo visible → buscar → pulsar resultado → detalle → volver → cargar más al hacer scroll.

- [X] T023 [US3] `integration_test/app_test.dart`: `IntegrationTestWidgetsFlutterBinding`; app en `ProviderScope(overrides:[movieUseCasesProvider→MovieUseCases(mockRepository con fixtures)])`; verifica catálogo (Populares/Mejor valoradas), búsqueda que muestra resultados, navegación listado→detalle→volver, y cargar más al hacer scroll
- [X] T024 [P] [US3] `test_driver/integration_test.dart`: runner mínimo para `flutter drive` (`integrationDriver()`)

**Checkpoint**: Flujos E2E cubiertos.

---

## Phase 6: Polish & Cross-Cutting

**Purpose**: Cobertura, limpieza y verificación final.

- [X] T025 Ejecutar `flutter test --coverage` y verificar cobertura de líneas **≥ 80%** en `lib/features/home/{domain,data,presentation}` y `lib/core/api` (revisar `coverage/lcov.info`)
- [X] T026 [P] Verificar que **no queda ningún** `import 'package:mocktail/...'` y que `flutter analyze` está limpio
- [X] T027 [P] Actualizar `README.md`/`quickstart` con los comandos de test (unit, integración `flutter test integration_test` / `flutter drive`, cobertura)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sin dependencias
- **Foundational (Phase 2)**: depende de Setup — BLOQUEA todas las user stories
- **US1 (Phase 3)** y **US2 (Phase 4)**: dependen de Foundational; US2 (T012–T014) depende de los archivos creados en US1
- **US3 (Phase 5)**: depende de Foundational (fixtures + mocks)
- **Polish (Phase 6)**: depende de todas las anteriores (la cobertura se mide sobre la suite completa)

### Within Each User Story

- US1 crea los archivos de test de ViewModel; US2 los amplía con reglas de negocio (mismo archivo → secuencial)
- Domain y Data (T016–T022) son independientes entre sí → paralelizables

### Parallel Opportunities

- Fixtures T006/T007 en paralelo
- US1: T009/T010/T011 en paralelo (archivos distintos)
- US2: T015, T016, T017, T018, T019, T020, T021, T022 en paralelo (archivos distintos)

---

## Parallel Example: User Story 2 (capas domain + data)

```bash
Task: "movie_use_cases_test.dart"           # domain
Task: "movie_genre_test.dart"               # domain
Task: "movie_model_test.dart"               # data
Task: "movie_detail_model_test.dart"        # data
Task: "movie_repository_remote_test.dart"   # data
Task: "movie_data_source_remote_test.dart"  # data
Task: "api_config_test.dart"                # data
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1: Setup (deps + limpieza)
2. Phase 2: Foundational (mocks + fixtures + utils) — CRÍTICO
3. Phase 3: US1 (transiciones de estado con `container.listen`)
4. **STOP y VALIDAR**: correr los tests de presentación
5. Continuar con US2 (cobertura por capa) → US3 (integración)

### Incremental Delivery

1. Setup + Foundational → infraestructura lista
2. US1 → transiciones verificadas (MVP)
3. US2 → cobertura de las 3 capas
4. US3 → integración E2E
5. Polish → cobertura ≥ 80% + limpieza

---

## Notes

- [P] = archivos distintos, sin dependencias
- Cada ViewModel: US1 (transiciones) + US2 (reglas) sobre el mismo archivo → US2 depende de US1
- Verificar que ningún test depende de la red real ni de esperas arbitrarias
- Commit tras cada capa/grupo lógico
