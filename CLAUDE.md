<!-- SPECKIT START -->
Active feature: `004-cobertura-tests` (cobertura de tests unitarios + integración).
For technologies, project structure, and commands, read the current plan:
`specs/004-cobertura-tests/plan.md`. Prior features: `001-arquitectura-base`,
`002-tmdb-peliculas-reales`, `003-catalogo-detalle-busqueda`.

Feature 004: pruebas UNITARIAS de los ViewModels (catálogo, búsqueda, detalle) que
aseveran transiciones `UIState` (UILoading → UISuccess/UIFail) con
`container.listen(provider, (prev,next){…}, fireImmediately: true)`; dobles con
**mockito** (codegen `@GenerateNiceMocks` + build_runner) mockeando `MovieRepository`
(se sobrescribe `movieUseCasesProvider`); pruebas de INTEGRACIÓN con el driver de
Flutter (`integration_test`, fixtures, sin red). Se ELIMINAN los widget tests y se
RETIRA mocktail. Cobertura de presentación ≥ 80% (`flutter test --coverage`).

Feature 003: design system Netflix (Atomic Design) en `lib/design_system/`; pantallas
catálogo (Popular/Top Rated), búsqueda con debounce 400 ms, detalle. Estados de
presentación en `viewmodels/states/` (PagedMoviesState, CatalogState). Convención UI:
DRY + widgets como clases (nunca `Widget _buildX`).

Stack: Flutter 3.38.6 / Dart 3.10.7 · flutter_riverpod (manual DI, no codegen) ·
freezed + build_runner · fluro (routing) · flutter_test + mockito · integration_test.
Architecture: feature-first Clean Architecture (data/domain/presentation) + `core/`.
MVVM in presentation (Notifier ViewModels → `UIState<T>`). El repositorio devuelve
entidades (`PageResult<Movie>`/`MovieDetail`) y es el único lugar del mapeo
`MovieModel → Movie`. domain must not import data/presentation; `MovieModel` stays in data.
<!-- SPECKIT END -->
