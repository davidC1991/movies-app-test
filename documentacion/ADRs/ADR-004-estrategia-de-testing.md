# ADR-004 — Estrategia de testing (unitario por capa + integración + E2E real)

- **Estado**: Aceptado
- **Fecha**: 2026-07-01
- **Contexto de la feature**: `specs/004-cobertura-tests`
- **Depende de**: [ADR-003 — Design System y pantallas](./ADR-003-design-system-y-pantallas.md) · [ADR-002 — Integración TMDB](./ADR-002-integracion-tmdb.md) · [ADR-001 — Arquitectura](./ADR-001-arquitectura-de-la-app.md)
- **Decisores**: Equipo mobile

---

## 1. Contexto

El ejercicio exige **pruebas unitarias** y valora la escalabilidad. Con las tres features
previas completas (arquitectura, TMDB real, pantallas sobre el design system), esta feature
define y establece la **estrategia de pruebas** de la app: cobertura de las tres capas de la
Clean Architecture, verificación de las transiciones de estado de los ViewModels, y pruebas
que ejercitan la app de extremo a extremo (con datos simulados y contra la API real).

## 2. Decisiones

### D1 — Dobles de prueba con **mockito** (codegen), se retira mocktail
- Los mocks se generan con `@GenerateNiceMocks([MockSpec<MovieRepository>(), MockSpec<MovieDataSource>(), MockSpec<MovieService>()])` en `test/helpers/mocks.dart` → `dart run build_runner build` genera `mocks.mocks.dart`.
- `NiceMock` devuelve dummies para métodos no stubbeados. `ApiResponse` es **sealed** → no se puede autogenerar dummy: se registra con `provideDummy<ApiResponse<...>>(EmptyApiResponse(...))` en los tests del repositorio.
- Se **elimina** `mocktail` del proyecto (antes convivía en 7 tests).

### D2 — Mockear en la **frontera de cada capa**
- **ViewModels / casos de uso** → mock `MovieRepository` (se sobrescribe `movieUseCasesProvider` con `MovieUseCases(mockRepository)`: ejercita el caso de uso real sobre un repositorio simulado).
- **Repositorio** → mock `MovieDataSource`.
- **Data source** → mock `MovieService` (retrofit).
- **Modelos**, `MovieGenre`, `ApiConfig`, `PagedMoviesState` → prueba directa (sin mocks).

### D3 — Transiciones de estado con `container.listen(..., fireImmediately: true)`
- Los tests de ViewModel **aseveran la secuencia de estados** emitidos (`UILoading → UISuccess`/`UIFail`), no solo el estado final. Se capturan con un helper `recordStates(container, provider)` que registra cada emisión desde la creación (emisión inmediata).
- El camino feliz **falla** si aparece un `UIFail`. Es la traducción del patrón `fetchCifsBco` a este proyecto (que expone `UIState<T>` directo, no un objeto de estado con sub-campos).

### D4 — Pruebas unitarias en las **tres capas**
- **Domain**: `MovieUseCases` (delegación al repositorio), `MovieGenre.fromId`, igualdad de entidades.
- **Data**: `fromJson` de modelos (+`GenresConverter`, `backdrop_path`), `MovieRepositoryRemote` (`ApiResponse` → entidad, `hasMore = page < totalPages`, lanzar en error/vacío), `MovieDataSourceRemote` (envoltura de `MovieService`), `ApiConfig`, y el `ApiResponseHandlerMixin` (ramas de error: timeout/cancel/cert/unknown/204/genérico).
- **Presentation**: ViewModels (transiciones + reglas de paginación/búsqueda/detalle), `PagedMoviesState`, `CatalogState`.

### D5 — Dos niveles de prueba de la app completa (mismos flujos, distinto origen de datos)
- **Integración con mocks** (`integration_test/flujos_integracion_mocks_test.dart`): repositorio mockeado con fixtures; **determinista**, sin red ni token → apta para CI.
- **End-to-end real** (`integration_test/flujos_e2e_real_test.dart`): arranca `MoviesApp` **sin overrides**, pegando a la **API real de TMDB** con el `.env`; aserciones **resilientes** (`pumpUntilFound` con timeout) por la latencia/variabilidad de la red.
- Ambos usan el **driver de Flutter** (`integration_test` + `IntegrationTestWidgetsFlutterBinding`); `test_driver/integration_test.dart` permite `flutter drive`.
- Los **widget tests** previos (con mocktail) se **eliminan**: sus flujos quedan cubiertos por la integración.

### D6 — Estructura de tests **espejo de `lib/`** (feature-first)
- Cada test vive en la ruta gemela del archivo que prueba: `test/features/home/{domain,data,presentation}/…`, `test/core/api/…`.
- `test/fixtures/` (entidades + JSON crudo) y `test/helpers/` (mocks + `provider_test_utils`) son soporte transversal (no espejan un archivo concreto).

### D7 — Determinismo y aislamiento
- Sin red real ni credenciales en unitarios/integración-mocks; sin esperas arbitrarias.
- Cada prueba recrea su `ProviderContainer`/mocks (`addTearDown`).
- El debounce (comportamiento temporal) se ejercita en integración con el reloj del `WidgetTester`; el `SearchViewModel` no incluye debounce (vive en el widget), por lo que sus unitarios son deterministas.
- El router de fluro es un **singleton estático**: sus rutas se registran una sola vez (`setUpAll(AppRouter.setup)`) para no lanzar "Default route was already defined".

### D8 — Cobertura ≥ 80% de la lógica
- `flutter test --coverage` → `coverage/lcov.info`.
- Se mide la **lógica escrita a mano**: se excluye código generado (`*.g.dart`/`*.freezed.dart`/`*.mocks.dart`), la **UI** (cubierta por integración/E2E, no por unitarios) y el **wiring de DI** (`dio_provider`, `home_providers`).

## 3. Pirámide de pruebas

```mermaid
flowchart TB
    subgraph E2E["E2E real (flujos_e2e_real_test) — API TMDB en vivo"]
      E1[catálogo real → detalle → volver] ; E2[búsqueda real]
    end
    subgraph INT["Integración con mocks (flujos_integracion_mocks_test)"]
      I1[catálogo] ; I2[navegación listado↔detalle] ; I3[búsqueda]
    end
    subgraph UNIT["Unitarias por capa (test/features, test/core)"]
      subgraph P[presentation]
        VM[ViewModels: transiciones UIState] ; ST[PagedMoviesState/CatalogState]
      end
      subgraph D[data]
        MOD[fromJson +GenresConverter] ; REP[RepositoryRemote] ; DS[DataSourceRemote] ; CFG[ApiConfig] ; MIX[ApiResponseHandler]
      end
      subgraph DOM[domain]
        UC[MovieUseCases] ; GEN[MovieGenre] ; ENT[entidades]
      end
    end

    UNIT --> INT --> E2E
    classDef u fill:#e8f5e9,stroke:#43a047; classDef i fill:#e3f2fd,stroke:#1e88e5; classDef e fill:#fff3e0,stroke:#fb8c00;
    class VM,ST,MOD,REP,DS,CFG,MIX,UC,GEN,ENT u; class I1,I2,I3 i; class E1,E2 e;
```

## 4. Cómo se inyectan los dobles por capa

```mermaid
flowchart LR
    subgraph test[Test]
      MR[MockMovieRepository] ; MDS[MockMovieDataSource] ; MS[MockMovieService]
    end
    MR -->|MovieUseCases(mock) via override| VM[ViewModels / MovieUseCases]
    MDS --> REPO[MovieRepositoryRemote]
    MS --> DSR[MovieDataSourceRemote]
```

## 5. Estructura de archivos de test

```text
test/
├── core/api/
│   ├── api_config_test.dart
│   └── remote/api_response_handler_mixin_test.dart
├── features/home/
│   ├── domain/{usecases,enums,entities}/*_test.dart
│   ├── data/{models,repositories,datasources}/*_test.dart
│   └── presentation/viewmodels/[states/]*_test.dart
├── fixtures/{movie_fixtures,json_fixtures}.dart
└── helpers/{mocks.dart, mocks.mocks.dart, provider_test_utils.dart}

integration_test/
├── flujos_integracion_mocks_test.dart   # integración con datos simulados
└── flujos_e2e_real_test.dart            # E2E contra TMDB real
test_driver/integration_test.dart        # runner de flutter drive
```

## 6. Comandos

```bash
# Unitarias + cobertura
flutter test --coverage

# Integración con mocks (determinista)
flutter test integration_test/flujos_integracion_mocks_test.dart -d <device>

# End-to-end real (requiere .env + internet)
flutter test integration_test/flujos_e2e_real_test.dart -d <device>

# Regenerar mocks tras cambiar contratos
dart run build_runner build --delete-conflicting-outputs
```

## 7. Consecuencias

**Positivas**
- Cobertura real de las tres capas; las transiciones de estado quedan protegidas contra regresiones.
- Dos niveles de prueba de app: uno determinista para CI y uno E2E que valida la pila completa contra TMDB.
- Estructura de tests espejo → encontrar el test de un archivo es trivial.
- Mockito con codegen da mocks tipados y verificables (`verify`/`verifyNever`).

**Negativas / trade-offs**
- Mockito requiere paso de codegen (`build_runner`) frente al enfoque runtime de mocktail.
- `ApiResponse` sealed obliga a `provideDummy` en los tests del repositorio.
- El E2E real es **no determinista** (datos vivos) y depende de red + token: se ejecuta bajo demanda, no en cada CI.
- La cobertura ≥ 80% se mide sobre la lógica (se excluye generado, UI y wiring de DI) — la UI se valida por integración/E2E, no por porcentaje de líneas.

## 8. Validación

- **66/66** pruebas unitarias verdes; **3/3** integración con mocks; **2/2** E2E real (emulador Android, TMDB en vivo).
- `flutter analyze` limpio. Cobertura de lógica ~92% (domain 100%, data ~83%, presentation VM+estados ~93%, core/api ~94%).

## 9. Trabajo futuro

- Integrar el gate de cobertura en CI (con `lcov`/`remove` de generados) y publicar el reporte.
- E2E adicionales (scroll/paginación real, estados de error de red) en un job programado.
- Golden tests de los componentes del design system.
