# Movies / Series

App móvil (Flutter) para el ejercicio técnico de Películas/Series: catálogo de
películas reales de TMDB categorizado en **Populares** y **Mejor valoradas**,
**buscador** con debounce y pantalla de **Detalle**, sobre un **design system**
reutilizable (Atomic Design, estética tipo Netflix, dark-only).

## Stack

- **Flutter 3.38.6 / Dart 3.10.7**
- **flutter_riverpod** — state management + inyección de dependencias (manual, sin codegen)
- **freezed** — modelado inmutable y uniones selladas (`build_runner` para generación)
- **fluro** — routing / navegación
- **flutter_test + mockito + integration_test** — pruebas unitarias, de integración y E2E

## Arquitectura

**Clean Architecture** organizada *feature-first*, con MVVM en la capa de presentación.
La regla de dependencia apunta hacia adentro: `presentation → domain ← data`.

```text
lib/
├── main.dart                 # Entry: setup del router + ProviderScope
├── app.dart                  # MaterialApp con el FluroRouter global
├── navigation/               # Routing global (Fluro) — fuera de core (depende de Flutter)
├── core/                     # Lógica Dart pura (sin Flutter): Result<T>, UIState<T>, Failure
├── design_system/            # Design System compartido (Atomic Design, tema Netflix)
│   ├── theme/                # tokens: colores, tipografía, espaciados, radios, sombras
│   ├── atoms/                # AppText, RatingBadge, AppChip, AppIconButton, Shimmer…
│   ├── molecules/            # DebouncedSearchBar, MediaCard, EmptyState, ErrorState…
│   └── organisms/            # MediaCarousel, CatalogSearchAppBar, DetailHeader
└── features/<feature>/
    ├── data/                 # datasources · models (+ toEntity) · repositories
    ├── domain/               # entities · repositories (contratos) · usecases
    └── presentation/         # navigation · providers (DI) · viewmodels (MVVM) · ui/widgets
```

### Flujo de datos

```text
data source → MovieModel ──(repository: model→entity)──► Result<List<Movie>> (empty/success/fail)
                                                              │
                                          GetMovies (usecase) ◄┘
                                                 │
                                    HomeViewModel (Notifier) → UIState<List<Movie>> → HomeScreen
```

- El **modelo** (`MovieModel`) muere en la capa data; se transpone a la entidad `Movie` en el repositorio.
- El **ViewModel** invoca el caso de uso y solo maneja entidades, exponiendo `UIState<T>` (loading/success/fail).
- La **DI** se resuelve con providers de Riverpod (`dataSource → repository → useCase`).

Convenciones detalladas en [`lib/features/README.md`](lib/features/README.md).

## Configuración (TMDB)

1. Crea una cuenta en https://www.themoviedb.org y ve a **Settings → API**.
2. Copia tu **API Read Access Token** (v4, empieza con `eyJ...`).
3. Crea un archivo **`.env`** en la raíz (hay plantilla en `.env.example`):
   ```env
   TMDB_TOKEN=eyJ... (tu Read Access Token)
   ```
   El `.env` está en `.gitignore` (no se versiona).

## Ejecutar

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera *.freezed.dart / *.g.dart
flutter run
```

## Pantallas

- **Catálogo (Home)**: filas horizontales estilo Netflix de **Populares** y **Mejor
  valoradas** (póster + rating) con **scroll infinito** por categoría. Arriba, una
  **barra de búsqueda** con **debounce de 400 ms**: al escribir filtra las películas
  y actualiza la vista; al limpiar/volver restaura el catálogo por defecto.
- **Detalle**: backdrop + póster + título + rating + géneros + sinopsis.
- Toda pantalla comunica sus estados de **carga** (shimmer/spinner), **vacío** y
  **error** (con reintentar).

## Pruebas

```bash
# Unitarias (3 capas) + reporte de cobertura
flutter test --coverage

# Integración con datos simulados (mocks) — determinista, sin red, requiere emulador
flutter test integration_test/flujos_integracion_mocks_test.dart -d <device>

# End-to-end REAL contra TMDB — requiere emulador + .env con TMDB_TOKEN + internet
flutter test integration_test/flujos_e2e_real_test.dart -d <device>

# o con el runner clásico (flutter drive):
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/flujos_integracion_mocks_test.dart
```

Estrategia (dobles con **mockito** + `@GenerateNiceMocks`, estado con
`container.listen(..., fireImmediately: true)`):

- **Unitarias por capa** — *domain* (`MovieUseCases`, `MovieGenre`), *data*
  (`fromJson` de modelos + `GenresConverter`, `MovieRepositoryRemote`,
  `MovieDataSourceRemote`, `ApiConfig`, manejo de `ApiResponse`) y *presentation*
  (transiciones `UIState` de los ViewModels + reglas de paginación/búsqueda/detalle).
- **Integración** — recorridos reales con datos simulados: catálogo, búsqueda,
  listado ↔ detalle ↔ volver, cargar más al hacer scroll.

Cobertura de la lógica ≥ 80% (`coverage/lcov.info`), excluyendo código generado
(`*.g.dart`/`*.freezed.dart`/mocks), la UI (cubierta por integración) y el wiring de DI.

## Estado / pendiente

Implementadas las tres pantallas (catálogo, búsqueda, detalle) sobre el design system.
Posibles mejoras futuras: dominio de **Series** (endpoints `/tv/*`), persistencia de
favoritos/watchlist, y empaquetar la fuente Inter (hoy se usa la familia del sistema
con la misma escala tipográfica).

## Uso de IA

Todo el proyecto se desarrolló con asistencia de IA (Claude Code) mediante el flujo
Spec Kit (`/speckit-specify` → `/clarify` → `/plan` → `/tasks` → `/implement`) sobre
tres features versionadas en `specs/` (`001-arquitectura-base`, `002-tmdb-peliculas-reales`,
`003-catalogo-detalle-busqueda`). El **design system** (tema Netflix + componentes
Atomic Design) y su **verificación de calidad** (tokens, reutilización, regla de
widgets como clases, accesibilidad) los produjo un subagente especializado de UI/UX.
Las decisiones de diseño y arquitectura se revisaron y validaron manualmente.
