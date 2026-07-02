---
description: "Task list — Catálogo, búsqueda y detalle de películas"
---

# Tasks: Catálogo, búsqueda y detalle de películas

**Input**: Design documents from `/specs/003-catalogo-detalle-busqueda/`
**Prerequisites**: plan.md (required), spec.md (required)

**Tests**: INCLUIDOS — el ejercicio técnico exige Pruebas Unitarias.

**Organization**: Tareas agrupadas por user story para implementar y probar cada una de forma independiente.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede correr en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: US1 / US2 / US3
- Rutas de archivo exactas en cada descripción

## Path Conventions

- Mobile app (Flutter): código en `lib/`, tests en `test/`
- Design system compartido en `lib/design_system/` (YA IMPLEMENTADO — se reutiliza, no se recrea)

## Convenciones OBLIGATORIAS (aplican a TODA tarea de UI)

- **DRY + widgets como clases (NON-NEGOTIABLE)**: cada sub-árbol reutilizable/compuesto es su propia clase de widget (`StatelessWidget`/`ConsumerWidget`) con `const` constructor cuando aplique. **Prohibido** construir widgets dentro de métodos privados o públicos (`Widget _buildX(...)`).
- **Reutilizar el design system**: usar atoms/molecules/organisms de `lib/design_system/`; no duplicar UI ni hardcodear colores/espaciados fuera de los tokens.
- Cada user story cierra con una **tarea de verificación del agente UI/UX** (tema Netflix + design system + DRY).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verificar base ya existente (design system + tema aplicado).

- [X] T001 Verificar que `lib/app.dart` usa `AppTheme.dark` (tema Netflix) y que `flutter analyze` está limpio sobre `lib/design_system/`
- [X] T002 [P] Verificar que el barrel `lib/design_system/design_system.dart` exporta todos los componentes usados por las pantallas (atoms, molecules, organisms)

**Checkpoint**: Base visual lista para consumir desde las features.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Piezas transversales que necesitan TODAS las user stories. Bloquean el inicio de US1–US3.

**⚠️ CRITICAL**: Ninguna user story puede empezar hasta completar esta fase.

- [X] T003 Añadir `ApiConfig.backdropUrl(String? path)` (tamaño w780) en `lib/core/api/api_config.dart` para el backdrop del Detalle
- [X] T004 Verificar/exponer en providers los 4 casos de uso (GetPopularMovies, GetTopRatedMovies, SearchMovies, GetMovieDetail) desde `lib/features/home/presentation/providers/home_providers.dart`
- [X] T005 [P] Crear mapper `Movie → MediaCardData` (id, posterUrl vía `ApiConfig.posterUrl`, title, rating) en `lib/features/home/presentation/viewmodels/media_card_mapper.dart`
- [X] T006 [P] Añadir ruta de Detalle (`/movie/:id`) en `lib/navigation/route_paths.dart` y registrarla en `lib/features/home/presentation/navigation/home_routes.dart` (fluro)

**Checkpoint**: Datos, navegación y mapeo listos — las user stories pueden comenzar.

---

## Phase 3: User Story 1 - Explorar el catálogo por categorías (Priority: P1) 🎯 MVP

**Goal**: Pantalla principal con filas horizontales de "Populares" y "Mejor valoradas" (póster + rating), con scroll incremental y estados carga/vacío/error.

**Independent Test**: Abrir la app sin buscar ni navegar: aparecen las dos categorías con películas; al desplazarse se cargan más resultados.

### Tests for User Story 1 ⚠️

- [X] T007 [P] [US1] Test unitario del ViewModel de catálogo (carga Popular + Top Rated, paginación al `loadMore`, estados success/fail/loadingMore) en `test/unit/catalog_view_model_test.dart`
- [X] T008 [P] [US1] Widget test: `HomeScreen` muestra dos `MediaCarousel` ("Populares", "Mejor valoradas") y `MediaCarouselSkeleton` en carga, en `test/widget/home_screen_catalog_test.dart`

### Implementation for User Story 1

- [X] T009 [US1] Crear `CatalogViewModel` (dos listas paginadas: popular y topRated → `UIState<CatalogState>`) en `lib/features/home/presentation/viewmodels/catalog_view_model.dart` (depende de T004, T005)
- [X] T010 [US1] Registrar el provider del `CatalogViewModel` en `lib/features/home/presentation/providers/home_providers.dart`
- [X] T011 [US1] Refactorizar `lib/features/home/presentation/ui/home_screen.dart` para consumir `CatalogSearchAppBar` + dos `MediaCarousel` (Popular, Top Rated) usando `MediaCardData`; widgets como clases (sin `_buildX`)
- [X] T012 [P] [US1] Extraer widget-clase `CatalogView` (fila de carruseles + estados vacío/error con `EmptyState`/`ErrorState`) en `lib/features/home/presentation/ui/widgets/catalog_view.dart`
- [X] T013 [US1] Cablear `onTap` de cada `MediaCard` para navegar a `/movie/:id` (usa la ruta de T006)
- [X] T014 [US1] **Verificación UI/UX (agente `movie-ui-ux`)**: confirmar tema Netflix (tokens, sin hardcode), reutilización del design system, estados carga/vacío/error, a11y ≥44dp y ausencia de `Widget _buildX` en el catálogo

**Checkpoint**: US1 totalmente funcional y verificable de forma independiente (MVP).

---

## Phase 4: User Story 2 - Buscar películas por nombre (Priority: P2)

**Goal**: Barra de búsqueda superior con debounce de 400 ms que reemplaza la vista por los resultados; al limpiar/volver restaura el catálogo.

**Independent Test**: Escribir un término y pausar → la pantalla muestra coincidencias; borrar/volver → reaparece el catálogo por categorías.

### Tests for User Story 2 ⚠️

- [X] T015 [P] [US2] Test unitario del `SearchViewModel`: debounce de 400 ms (usar `fakeAsync`), dispara con ≥1 carácter no vacío, texto en blanco/espacios = "sin búsqueda", sin resultados → estado vacío, búsquedas encadenadas → prevalece el último término, en `test/unit/search_view_model_test.dart`
- [X] T016 [P] [US2] Widget test: al escribir en `DebouncedSearchBar` la `HomeScreen` cambia a resultados y al limpiar restaura el catálogo, en `test/widget/home_screen_search_test.dart`

### Implementation for User Story 2

- [X] T017 [US2] Crear `SearchViewModel` (usecase `SearchMovies`, estados carga/éxito/vacío/error; expone limpiar → restaura catálogo) en `lib/features/home/presentation/viewmodels/search_view_model.dart`
- [X] T018 [US2] Registrar el provider del `SearchViewModel` en `lib/features/home/presentation/providers/home_providers.dart`
- [X] T019 [US2] Integrar `DebouncedSearchBar` (callbacks `onChanged`/`onClear`) en `CatalogSearchAppBar` dentro de `home_screen.dart`; alternar entre `CatalogView` y una `SearchResultsView` según haya término activo
- [X] T020 [P] [US2] Extraer widget-clase `SearchResultsView` (grid/lista de `MediaCard` + `EmptyState` "sin resultados" + `ErrorState`) en `lib/features/home/presentation/ui/widgets/search_results_view.dart`
- [X] T021 [US2] **Verificación UI/UX (agente `movie-ui-ux`)**: confirmar reutilización de componentes, estados de búsqueda (vacío/sin resultados/error), tema Netflix y DRY (sin `_buildX`)

**Checkpoint**: US1 y US2 funcionan de forma independiente.

---

## Phase 5: User Story 3 - Ver el detalle de una película (Priority: P3)

**Goal**: Pantalla de Detalle con backdrop, póster, título, rating, géneros y sinopsis; navegación ida/vuelta desde catálogo o resultados.

**Independent Test**: Pulsar una película → abre el detalle con su información; volver → regresa a la lista conservando su estado.

### Tests for User Story 3 ⚠️

- [X] T022 [P] [US3] Test unitario del `MovieDetailViewModel` (carga por id → success, error → fail con retry) en `test/unit/movie_detail_view_model_test.dart`
- [X] T023 [P] [US3] Widget test: `MovieDetailScreen` renderiza `DetailHeader` (título, rating, géneros como `AppChip`) y sinopsis; estado carga/error, en `test/widget/movie_detail_screen_test.dart`
- [X] T024 [P] [US3] Test de navegación: desde una `MediaCard` del catálogo se abre el Detalle y `volver` regresa, en `test/widget/navigation_list_to_detail_test.dart`

### Implementation for User Story 3

- [X] T025 [US3] Crear `MovieDetailViewModel` (usecase `GetMovieDetail` → `UIState<MovieDetail>`) en `lib/features/home/presentation/viewmodels/movie_detail_view_model.dart`
- [X] T026 [US3] Registrar el provider (familia por id) del `MovieDetailViewModel` en `lib/features/home/presentation/providers/home_providers.dart`
- [X] T027 [US3] Crear `MovieDetailScreen` consumiendo `DetailHeader` (backdrop vía `ApiConfig.backdropUrl`) + `AppText` para sinopsis; widgets como clases, en `lib/features/home/presentation/ui/movie_detail_screen.dart`
- [X] T028 [US3] Conectar la ruta `/movie/:id` (T006) al `MovieDetailScreen` en `home_routes.dart`
- [X] T029 [US3] **Verificación UI/UX (agente `movie-ui-ux`)**: confirmar `DetailHeader` reutilizado, scrim/legibilidad sobre backdrop, tema Netflix, estados carga/error y DRY (sin `_buildX`)

**Checkpoint**: Las tres user stories funcionan de forma independiente.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Calidad transversal a todas las user stories.

- [X] T030 [P] Auditoría DRY global: revisar `lib/features/home/presentation/ui/**` y confirmar que NO existan widgets en métodos (`Widget _buildX`); cada sub-árbol es una clase de widget
- [X] T031 [P] Deprecar/retirar widgets legado (`lib/features/home/presentation/ui/widgets/movie_tile.dart`) si quedaron sin uso tras el refactor
- [X] T032 Ejecutar `flutter analyze` (0 issues) y `flutter test` (toda la suite verde)
- [X] T033 **Verificación UI/UX final (agente `movie-ui-ux`)**: revisión visual de la app corriendo contra SC-004/SC-005/SC-006 (estados en todas las pantallas, reutilización de componentes, identidad visual consistente)
- [ ] T034 Gate final del `code-reviewer`: capas (domain sin imports de data/presentation), MVVM correcto, widgets como clases, uso del design system
- [X] T035 [P] Actualizar `README.md` con las pantallas, el design system y cómo se usó la IA

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sin dependencias
- **Foundational (Phase 2)**: depende de Setup — BLOQUEA todas las user stories
- **User Stories (Phase 3–5)**: dependen de Foundational; luego pueden ir en paralelo o en orden P1 → P2 → P3
- **Polish (Phase 6)**: depende de las user stories deseadas

### User Story Dependencies

- **US1 (P1)**: arranca tras Foundational. Sin dependencias de otras stories.
- **US2 (P2)**: arranca tras Foundational. Comparte `HomeScreen` con US1 (integra la barra de búsqueda) pero es testeable de forma independiente.
- **US3 (P3)**: arranca tras Foundational. La navegación se cablea en US1 (T013); el Detalle en sí es independiente.

### Within Each User Story

- Tests primero (deben fallar antes de implementar)
- ViewModel → providers → UI → verificación UI/UX

### Parallel Opportunities

- T005 y T006 en paralelo (Foundational)
- Tests marcados [P] de cada story en paralelo
- T012/T020 (widget-clases) en paralelo con sus ViewModels cuando no comparten archivo

---

## Parallel Example: User Story 1

```bash
# Tests de US1 juntos:
Task: "Test unitario del ViewModel de catálogo en test/unit/catalog_view_model_test.dart"
Task: "Widget test de HomeScreen (dos carruseles) en test/widget/home_screen_catalog_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1: Setup
2. Phase 2: Foundational (CRÍTICO — bloquea todo)
3. Phase 3: US1 (catálogo Popular + Top Rated)
4. **STOP y VALIDAR**: probar US1 de forma independiente
5. Demo del MVP

### Incremental Delivery

1. Setup + Foundational → base lista
2. US1 → probar → demo (MVP)
3. US2 (búsqueda) → probar → demo
4. US3 (detalle) → probar → demo

---

## Notes

- [P] = archivos distintos, sin dependencias
- Cada user story es completable y testeable de forma independiente
- Verificar que los tests fallan antes de implementar
- Commit tras cada tarea o grupo lógico
- **Recordatorio permanente**: DRY + widgets como clases (sin `Widget _buildX`), reutilizando `lib/design_system/`. La verificación de tema Netflix y del design system es responsabilidad del agente `movie-ui-ux` en cada story.
