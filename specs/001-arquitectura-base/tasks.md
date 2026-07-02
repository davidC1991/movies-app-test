---
description: "Task list for Arquitectura Base (Clean Architecture Scaffold)"
---

# Tasks: Arquitectura Base (Clean Architecture Scaffold)

**Input**: Design documents from `/specs/001-arquitectura-base/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: INCLUIDOS — el spec exige pruebas unitarias del flujo domain/data (FR-011).

**Organization**: Tareas agrupadas por user story para implementación y prueba independientes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede correr en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: A qué user story pertenece (US1, US2, US3)
- Todas las rutas son relativas a la raíz del repo

## Path Conventions

Mobile app (Flutter, single package). Código en `lib/`, pruebas en `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Inicialización de dependencias y esqueleto de carpetas

- [X] T001 Añadir dependencias en `pubspec.yaml` (`flutter_riverpod: ^2.6.1`, `freezed_annotation: ^2.4.4`, `fluro: ^2.0.5`; dev: `build_runner: ^2.4.13`, `freezed: ^2.5.7`, `mocktail: ^1.0.4`) y ejecutar `flutter pub get`
- [X] T002 [P] Crear el esqueleto de carpetas feature-first: `lib/navigation/`, `lib/core/{error,result,state}/`, `lib/features/home/data/{datasources,models,repositories}/`, `lib/features/home/domain/{entities,repositories,usecases}/`, `lib/features/home/presentation/{navigation,providers,viewmodels,ui/widgets}/`, `test/features/home/{domain,data}/`
- [X] T003 [P] Verificar `analysis_options.yaml` (lints activos) y crear `build.yaml` opcional para Freezed si se requiere
- [X] T004 Envolver la app en `ProviderScope` en `lib/main.dart` (bootstrap mínimo de Riverpod)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Tipos transversales de lógica Dart pura en `core/` — bloquean TODAS las user stories

**⚠️ CRITICAL**: Ninguna user story puede completarse hasta terminar esta fase.

- [X] T005 [P] Crear `Failure` (unión sellada Freezed: `serverFailure`, `unexpected`) en `lib/core/error/failure.dart`
- [X] T006 [P] Crear `Result<T>` (unión sellada Freezed: `empty` / `success(T)` / `fail(Failure)`) en `lib/core/result/result.dart`
- [X] T007 [P] Crear `UIState<T>` (unión sellada Freezed: `loading` / `success(T)` / `fail(Failure)`) en `lib/core/state/ui_state.dart`
- [X] T008 Ejecutar `dart run build_runner build --delete-conflicting-outputs` para generar los `*.freezed.dart` de `Failure`, `Result<T>` y `UIState<T>` (depende de T005, T006, T007)

**Checkpoint**: `core/` compila con los tres tipos sellados generados y sin dependencias de Flutter.

---

## Phase 3: User Story 1 - Verificar el flujo end-to-end de la arquitectura (Priority: P1) 🎯 MVP

**Goal**: Pulsar un botón en `home` que haga viajar `List<Movie>` por las tres capas (presentation → domain → data → mock → back), demostrando el cableado con Riverpod.

**Independent Test**: Ejecutar la app, pulsar el botón y ver la lista placeholder tras la resolución del `Future` (estado loading → success), con estado fail si el mock se configura para fallar.

### Domain + Data models (US1)

- [X] T009 [P] [US1] Crear entidad `Movie` (Freezed: `id`, `title`) en `lib/features/home/domain/entities/movie.dart`
- [X] T010 [P] [US1] Crear contrato abstracto `MovieRepository` (`Future<Result<List<Movie>>> getMovies()`) en `lib/features/home/domain/repositories/movie_repository.dart`
- [X] T011 [P] [US1] Crear `MovieModel` (Freezed) con `Movie toEntity()` en `lib/features/home/data/models/movie_model.dart` (depende de T009)
- [X] T012 [US1] Ejecutar `dart run build_runner build --delete-conflicting-outputs` para generar `movie.freezed.dart` y `movie_model.freezed.dart` **antes** de escribir sus consumidores (depende de T009, T011)

### Domain use case + Data sources (US1)

- [X] T013 [US1] Crear caso de uso `GetMovies` (callable que delega en el repositorio) en `lib/features/home/domain/usecases/get_movies.dart` (depende de T010)
- [X] T014 [US1] Crear `MovieMockDataSource` que devuelve `Future<List<MovieModel>>` con `Future.delayed` (latencia simulada, 2-3 películas) y flag para simular fallo, en `lib/features/home/data/datasources/movie_mock_datasource.dart` (depende de T011, T012)
- [X] T015 [US1] Implementar `MovieRepositoryImpl` (mapea model→entidad con `toEntity()`, envuelve en `Result` empty/success/fail, sin propagar excepciones) en `lib/features/home/data/repositories/movie_repository_impl.dart` (depende de T010, T011, T012, T014, T005, T006)

### Presentation (US1)

- [X] T016 [US1] Crear providers de DI manual (`movieDataSourceProvider` → `movieRepositoryProvider` → `getMoviesProvider`) en `lib/features/home/presentation/providers/home_providers.dart` (depende de T013, T014, T015)
- [X] T017 [US1] Crear `HomeViewModel` (`Notifier<UIState<List<Movie>>>`) que lee `getMoviesProvider`, expone `loadMovies()` y mapea `Result`→`UIState`, en `lib/features/home/presentation/viewmodels/home_view_model.dart` (depende de T007, T013, T016)
- [X] T018 [US1] Crear `HomeScreen` con el botón de verificación que dispara `loadMovies()` y renderiza `UIState` (loading/success/fail) en `lib/features/home/presentation/ui/home_screen.dart` (depende de T017)
- [X] T019 [US1] Cablear `lib/main.dart` para mostrar `HomeScreen` directamente (`home: HomeScreen()`, sin router aún) y arrancar la app (depende de T018, T004)

### Tests (US1)

- [X] T020 [P] [US1] Prueba unitaria de `GetMovies` con `MovieRepository` mockeado (mocktail): success/empty/fail, en `test/features/home/domain/get_movies_test.dart` (depende de T013)
- [X] T021 [P] [US1] Prueba unitaria de `MovieRepositoryImpl`: mapeo model→entidad y variantes `Result` (datos→success, vacío→empty, excepción→fail), en `test/features/home/data/movie_repository_impl_test.dart` (depende de T015)

**Checkpoint**: `flutter run` muestra `home`; el botón produce loading→success con la lista placeholder; `flutter test` pasa. **MVP entregable.**

---

## Phase 4: User Story 2 - Estructura de carpetas escalable y consistente (Priority: P2)

**Goal**: Dejar la estructura feature-first completa, consistente y documentada para replicar en nuevas features.

**Independent Test**: Inspeccionar `lib/` y confirmar que cada feature tiene `data`/`domain`/`presentation` con sus subcarpetas y que `core/` contiene solo lógica Dart pura.

- [X] T022 [US2] Verificar que todas las subcarpetas de capas existen y son consistentes (incl. `presentation/navigation/` y `presentation/ui/widgets/`); añadir `.gitkeep` en las que queden vacías
- [X] T023 [P] [US2] Extraer un widget reutilizable (p. ej. `MovieTile`) a `lib/features/home/presentation/ui/widgets/movie_tile.dart` y usarlo desde `HomeScreen` para demostrar el agrupamiento de widgets (depende de T018)
- [X] T024 [P] [US2] Documentar convenciones de la estructura por feature (dónde va cada tipo de archivo) en `lib/features/README.md`

**Checkpoint**: La estructura está completa y documentada; una nueva feature puede crearse replicando el patrón.

---

## Phase 5: User Story 3 - Routing con Fluro y modelado con Freezed (Priority: P3)

**Goal**: Navegar a `home` mediante el `FluroRouter` global que agrega las rutas hijas del feature; confirmar el uso de Freezed en el flujo.

**Independent Test**: Al arrancar, la app navega a `home` a través del router (no hardcodeado); el data source produce datos representados por clases Freezed.

- [X] T025 [P] [US3] Crear constantes de rutas globales en `lib/navigation/route_paths.dart` (p. ej. `home`)
- [X] T026 [US3] Crear rutas hijas del feature `home` (handlers Fluro que exponen `HomeScreen`) en `lib/features/home/presentation/navigation/home_routes.dart` (depende de T018, T025)
- [X] T027 [US3] Crear el `FluroRouter` global que agrega `home_routes` en `lib/navigation/app_router.dart` (depende de T025, T026)
- [X] T028 [US3] Crear `lib/app.dart` con `MaterialApp` usando `onGenerateRoute` del `FluroRouter` e `initialRoute = home`; actualizar `lib/main.dart` para usar `MoviesApp` en lugar del `home:` directo (depende de T027, T019)

**Checkpoint**: La app arranca navegando a `home` vía Fluro; el flujo de verificación sigue funcionando end-to-end.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validación de reglas arquitectónicas y cierre

- [X] T029 [P] Ejecutar `flutter analyze` y resolver cualquier error/warning (SC-006)
- [X] T030 [P] Verificar reglas arquitectónicas con `grep` según `quickstart.md`: domain sin imports a data/presentation (SC-003) y `MovieModel` confinado a data (SC-004a)
- [X] T031 [P] Actualizar `README.md` del proyecto con visión general de la arquitectura y aclaración del uso de IA (requisito del ADR)
- [X] T032 Ejecutar la suite completa `flutter test` y confirmar que todo pasa (SC-005)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sin dependencias — primero.
- **Foundational (Phase 2)**: depende de Setup — BLOQUEA todas las user stories.
- **US1 (Phase 3)**: depende de Foundational. Es el MVP.
- **US2 (Phase 4)**: depende de US1 (necesita `HomeScreen` para extraer el widget). Puede solaparse parcialmente.
- **US3 (Phase 5)**: depende de US1 (necesita `HomeScreen`). Independiente de US2.
- **Polish (Phase 6)**: depende de las fases implementadas.

### Story-level

- US1 es autónoma tras Foundational → **entregable como MVP sin US2 ni US3**.
- US2 y US3 son independientes entre sí; ambas solo requieren que exista `HomeScreen` (US1).

### Ruta crítica dentro de US1

```
T009 (Movie) ─┐
T010 (Repo)   ├─► T012 (build_runner gen) ─► T014 (datasource) ─► T015 (repo impl) ─► T016 ─► T017 ─► T018 ─► T019
T011 (Model) ─┘        │                                              │
                       └─► T013 (usecase) ──────────────────────────►┘
                                                                       └─► T020, T021 (tests)
```

> **Nota (F1 resuelta)**: la generación de Freezed (T012) corre **antes** de los consumidores (T014/T015), de modo que el código compila en cada paso.

---

## Parallel Execution Examples

**Phase 2 (Foundational)** — los tres tipos core en paralelo:
```
T005 (failure.dart) | T006 (result.dart) | T007 (ui_state.dart)  → luego T008 (build_runner)
```

**Phase 3 (US1)** — arranque en paralelo (entidad, contrato y modelo antes de generar):
```
T009 (Movie) | T010 (MovieRepository) | T011 (MovieModel)   → luego T012 (build_runner)
```
y las pruebas en paralelo una vez lista su dependencia:
```
T020 (get_movies_test) | T021 (movie_repository_impl_test)
```

**Phase 6 (Polish)** — validaciones en paralelo:
```
T029 (analyze) | T030 (grep reglas) | T031 (README)
```

---

## Implementation Strategy

### MVP First (recomendado)

1. Completar **Phase 1 + Phase 2** (setup + core).
2. Completar **Phase 3 (US1)** → **detente y valida**: `flutter run` + botón + `flutter test`. Esto ya demuestra que toda la base arquitectónica funciona (objetivo principal del ejercicio).
3. Añadir **US2** (consistencia/documentación) y **US3** (Fluro) de forma incremental.
4. Cerrar con **Phase 6** (analyze, reglas, README).

### Total de tareas: 32

| Fase | Tareas |
|------|--------|
| Phase 1 — Setup | T001–T004 (4) |
| Phase 2 — Foundational | T005–T008 (4) |
| Phase 3 — US1 (MVP) | T009–T021 (13) |
| Phase 4 — US2 | T022–T024 (3) |
| Phase 5 — US3 | T025–T028 (4) |
| Phase 6 — Polish | T029–T032 (4) |
