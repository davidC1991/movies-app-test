# Implementation Plan: Arquitectura Base (Clean Architecture Scaffold)

**Branch**: `001-arquitectura-base` | **Date**: 2026-07-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-arquitectura-base/spec.md`

## Summary

Establecer la base arquitectónica de la app de Películas/Series con **Clean Architecture** (capas `data`, `domain`, `presentation`) agrupada por feature, más una capa `core` compartida. Se demuestra el cableado end-to-end mediante una feature `home` con un botón que dispara el flujo completo: un data source mockeado (`await Future`) devuelve `List<MovieModel>`, el repositorio transpone modelo→entidad y devuelve `Result<List<Movie>>` (empty/success/fail), el caso de uso lo entrega al ViewModel, que expone `UIState<T>` a la UI. DI con providers de Riverpod **manuales (sin codegen)**, modelado con **Freezed**, routing con **Fluro**, y pruebas unitarias del flujo domain/data. No se construye UI final.

## Technical Context

**Language/Version**: Dart 3.10.7 / Flutter 3.38.6 (cumple el requisito del ADR ≥ 3.35.7)  
**Primary Dependencies**: `flutter_riverpod` (state management + DI, manual/no codegen), `freezed` + `freezed_annotation` (modelado inmutable y uniones selladas), `fluro` (routing), `build_runner` (codegen de Freezed únicamente)  
**Storage**: N/A (data source mockeado en memoria; sin persistencia ni API real de TMDB en esta feature)  
**Testing**: `flutter_test` + `mocktail` para dobles de prueba del data source/repositorio  
**Target Platform**: iOS y Android (app móvil Flutter)  
**Project Type**: Mobile app (Flutter, single package)  
**Performance Goals**: N/A funcional; el mock simula latencia (~300–800 ms) para ejercitar el estado loading  
**Constraints**: Regla de dependencia de Clean Architecture (domain no importa data ni presentation); `MovieModel` confinado a data; sin codegen de Riverpod  
**Scale/Scope**: 1 feature (`home`) + capa `core`; ~15-18 archivos fuente + pruebas. Base replicable para features futuras (listados, detalle, buscador)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

La constitución del proyecto (`.specify/memory/constitution.md`) está en estado **plantilla sin ratificar** (placeholders, sin principios concretos). No hay gates formales definidos.

**Evaluación**: PASS (no hay principios ratificados que violar). Se adoptan como principios de facto para esta feature, alineados con el ejercicio:
- **Separación de capas** (Clean Architecture) — cumplido por diseño.
- **Testabilidad** — el flujo domain/data se prueba unitariamente (FR-011).
- **Simplicidad / YAGNI** — solo se construye lo necesario para verificar la base; sin UI final ni API real.

No hay violaciones que justificar → sección *Complexity Tracking* vacía.

## Project Structure

### Documentation (this feature)

```text
specs/001-arquitectura-base/
├── plan.md              # Este archivo (/speckit-plan)
├── research.md          # Fase 0 (/speckit-plan)
├── data-model.md        # Fase 1 (/speckit-plan)
├── quickstart.md        # Fase 1 (/speckit-plan)
├── contracts/           # Fase 1 (/speckit-plan)
│   ├── movie_repository.md   # Contrato del repositorio (domain)
│   └── get_movies_usecase.md # Contrato del caso de uso
└── tasks.md             # Fase 2 (/speckit-tasks - NO lo crea /speckit-plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart                         # Entry: runApp(ProviderScope(child: MoviesApp()))
├── app.dart                          # MaterialApp + wiring del FluroRouter (onGenerateRoute)
├── navigation/                       # Routing global (código Flutter, fuera de core)
│   ├── app_router.dart               # FluroRouter principal; agrega las rutas de cada feature
│   └── route_paths.dart              # Constantes de rutas globales (home, ...)
├── core/                             # SOLO lógica Dart pura (sin dependencias de Flutter)
│   ├── error/
│   │   └── failure.dart              # Failure (Freezed sealed) — fallos de dominio
│   ├── result/
│   │   └── result.dart               # Result<T> (Freezed sealed): empty / success / fail
│   └── state/
│       └── ui_state.dart             # UIState<T> (Freezed sealed): loading / success / fail
└── features/
    └── home/
        ├── data/
        │   ├── datasources/
        │   │   └── movie_mock_datasource.dart   # await Future → List<MovieModel>
        │   ├── models/
        │   │   └── movie_model.dart             # MovieModel + toEntity() (mapeo)
        │   └── repositories/
        │       └── movie_repository_impl.dart   # implements MovieRepository; model→entity; Result
        ├── domain/
        │   ├── entities/
        │   │   └── movie.dart                   # Movie (Freezed entity)
        │   ├── repositories/
        │   │   └── movie_repository.dart        # abstract → Future<Result<List<Movie>>>
        │   └── usecases/
        │       └── get_movies.dart              # GetMovies (invoca el repositorio)
        └── presentation/
            ├── navigation/
            │   └── home_routes.dart             # Rutas hijas del feature; se exponen al app_router
            ├── providers/
            │   └── home_providers.dart          # DI manual: dataSource→repo→useCase providers
            ├── viewmodels/
            │   └── home_view_model.dart         # Notifier<UIState<List<Movie>>>; ref.read(useCase)
            └── ui/
                ├── home_screen.dart             # Botón de verificación (arnés mínimo)
                └── widgets/                     # Widgets reutilizables del feature

test/
└── features/
    └── home/
        ├── domain/
        │   └── get_movies_test.dart             # useCase con repo mock (success/empty/fail)
        └── data/
            └── movie_repository_impl_test.dart  # mapeo model→entity + variantes Result
```

**Structure Decision**: Estructura **feature-first** con las tres capas de Clean Architecture (`data`/`domain`/`presentation`) anidadas dentro de cada feature. Convenciones de ubicación:

- **`lib/navigation/`** (fuera de `core`): routing global. `app_router.dart` construye el `FluroRouter` principal y **agrega las rutas que cada feature expone** desde su `presentation/navigation/`. Va fuera de `core` porque depende de Flutter/widgets.
- **`lib/core/`**: exclusivamente **lógica Dart pura, sin dependencias de Flutter** (`Result<T>`, `UIState<T>`, `Failure`). Son tipos transversales que usarán todas las features y deben poder testearse sin el framework.
- **`features/<f>/presentation/navigation/`**: rutas **hijas del feature**, que se registran hacia el router principal (mantiene el routing colocalizado con su feature).
- **`features/<f>/presentation/ui/widgets/`**: widgets reutilizables/refactorizados propios del feature.
- **`features/<f>/presentation/providers/`**: DI manual con Riverpod (dataSource→repo→useCase).
- **`features/<f>/presentation/viewmodels/`**: ViewModels (MVVM) que leen los providers e invocan el caso de uso, exponiendo `UIState<T>`.

Guías de referencia: organización por feature `persefone/lib/features`; MVVM y providers `fin/auth_methods/ui` y `fin/auth_methods/providers`.

## Complexity Tracking

> No aplica — Constitution Check en PASS sin violaciones.
