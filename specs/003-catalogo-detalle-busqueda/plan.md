# Implementation Plan: Catálogo, búsqueda y detalle de películas

**Branch**: `003-catalogo-detalle-busqueda` | **Date**: 2026-07-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/003-catalogo-detalle-busqueda/spec.md`

## Summary

Construir las pantallas de la app sobre un **design system reutilizable** (Atomic Design) con estética tipo Netflix (dark-only): una pantalla principal (catálogo) con categorías **Popular** y **Top Rated** en filas horizontales, **barra de búsqueda con debounce de 400 ms** que filtra y actualiza la pantalla (y restaura el catálogo al limpiar/volver), y una pantalla de **Detalle** de película. El design system ya fue implementado en `lib/design_system/` por el agente UI/UX; este plan documenta esa base y define el trabajo restante: refactor de `HomeScreen` para consumir el design system, ViewModel de búsqueda, pantalla de Detalle, y la verificación de calidad visual/estructural a cargo del agente UI/UX.

## Technical Context

**Language/Version**: Dart 3.10.7 / Flutter 3.38.6
**Primary Dependencies**: flutter_riverpod (DI manual, sin codegen) · freezed + build_runner · fluro (routing) · dio + retrofit (TMDB) · cached_network_image · flutter_dotenv
**Storage**: N/A (sin persistencia local en esta feature; datos remotos de TMDB vía feature 002)
**Testing**: flutter_test + mocktail (unit/widget)
**Target Platform**: iOS 15+ / Android (app móvil)
**Project Type**: Mobile app (feature-first Clean Architecture + MVVM en presentation)
**Performance Goals**: catálogo visible < 3 s (SC-001); resultados de búsqueda < 2 s tras debounce (SC-002); scroll fluido a 60 fps
**Constraints**: tema único dark-only (estética Netflix); solo películas (series fuera de scope); búsqueda con debounce de 400 ms disparada con ≥1 carácter no vacío
**Scale/Scope**: 2 pantallas (Catálogo, Detalle) + 1 design system compartido (~23 archivos); dominio Movies únicamente

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

La constitución del proyecto (`.specify/memory/constitution.md`) está sin personalizar (plantilla), por lo que no impone gates formales. Se aplican, en su lugar, las convenciones de la arquitectura base (001) y del CLAUDE.md como gates de facto:

- **Clean Architecture por capas**: `domain` no importa `data`/`presentation`; el mapeo `MovieModel → Movie` vive solo en el repositorio. ✅ (se respeta)
- **MVVM en presentation**: ViewModels `Notifier` → `UIState<T>`; los widgets no contienen lógica de red. ✅
- **Design system sin dependencias a `features/`**: los componentes de `lib/design_system/` reciben datos primitivos/callbacks. ✅ (verificado por el agente UI/UX)
- **Convención UI — DRY + widgets como clases (NON-NEGOTIABLE)**: todo sub-árbol se extrae en su propia clase de widget; **prohibido** construir widgets dentro de métodos privados o públicos (`Widget _buildX(...)`). Reutilizar componentes del design system en lugar de duplicar. Este es criterio de revisión obligatorio.

Sin violaciones que justificar → **Complexity Tracking** vacío.

## Project Structure

### Documentation (this feature)

```text
specs/003-catalogo-detalle-busqueda/
├── plan.md              # Este archivo
├── spec.md              # Especificación (con Clarifications)
├── research.md          # Fase 0 (decisiones técnicas)
├── data-model.md        # Fase 1 (entidades de presentación / view-data)
├── quickstart.md        # Fase 1 (cómo correr y verificar)
├── contracts/           # Fase 1 (contratos de componentes del design system)
├── checklists/
│   └── requirements.md  # Checklist de calidad de la spec
└── tasks.md             # Fase 2 (/speckit-tasks — NO lo crea /speckit-plan)
```

### Source Code (repository root)

```text
lib/
├── app.dart                          # Usa AppTheme.dark (tema Netflix) [YA HECHO]
├── core/                             # state (UIState), api (TMDB), config
├── design_system/                    # [YA IMPLEMENTADO por el agente UI/UX]
│   ├── design_system.dart            # barrel
│   ├── theme/                        # app_colors, app_spacing, app_radius,
│   │                                 #   app_typography, app_durations,
│   │                                 #   app_shadows, app_theme
│   ├── atoms/                        # app_text, rating_badge, app_icon_button,
│   │                                 #   app_chip, app_spinner, shimmer,
│   │                                 #   gradient_scrim
│   ├── molecules/                    # debounced_search_bar, media_card,
│   │                                 #   section_header, empty_state, error_state
│   └── organisms/                    # media_carousel, catalog_search_app_bar,
│                                     #   detail_header
├── navigation/                       # app_router, route_paths (fluro)
└── features/
    └── home/
        ├── data/                     # models, datasources (retrofit), repository
        ├── domain/                   # entities (Movie, MovieDetail, PageResult),
        │                             #   usecases, repositories, enums
        └── presentation/
            ├── providers/            # home_providers (DI manual Riverpod)
            ├── viewmodels/           # home_view_model, paged_movies,
            │                         #   [NUEVO] search_view_model, [NUEVO] movie_detail_view_model
            ├── navigation/           # home_routes (+ ruta de Detalle)
            └── ui/                   # [REFACTOR] home_screen (consume design system),
                                      #   [NUEVO] movie_detail_screen,
                                      #   widgets/ (poster_image, movie_tile — legado)

test/
├── unit/                             # viewmodels (búsqueda debounce, paginación), repository
└── widget/                           # componentes del design system + pantallas
```

**Structure Decision**: Se mantiene la arquitectura feature-first + `core/` de la base 001, añadiendo `lib/design_system/` como capa transversal compartida (no pertenece a ninguna feature). La feature `home` consume el design system; el Detalle se implementa dentro de `home` (mismo dominio Movies) para no fragmentar el módulo.

## Phase 0 — Research (decisiones técnicas)

Salida detallada en `research.md`. Decisiones clave:

1. **Estética y tema**: dark-only estilo Netflix. Fuente de verdad: skill `ui-ux-pro-max` (estilo "Dark Mode (OLED)", paleta "Video Streaming/OTT", font-pairing "Modern Dark Cinema/Inter"). Acento rojo Netflix `#E50914`. Tokens centralizados en `lib/design_system/theme/`.
2. **Debounce de búsqueda**: 400 ms mediante `Timer` interno de `DebouncedSearchBar`; el widget solo expone callbacks (`onChanged` debounced, `onClear`). La orquestación del request vive en el ViewModel de búsqueda (SearchMovies), no en el widget.
3. **Estados de UI**: patrón `UIState<T>` (loading/success/fail) ya existente; loading con shimmer (`MediaCarouselSkeleton`), vacío con `EmptyState`, error con `ErrorState` + retry.
4. **Backdrop en Detalle**: TMDB entrega `backdrop_path`; se requiere añadir `ApiConfig.backdropUrl()` (hoy solo existe `posterUrl`).
5. **Búsqueda vs. catálogo**: la búsqueda **reemplaza** la vista; al limpiar/volver se restaura el catálogo por categorías (no se mezclan).
6. **Convención de widgets**: DRY + clases de widget; prohibido `Widget _buildX()`. Se refactoriza el `HomeScreen` actual para migrarlo a los organismos/moléculas del design system.

## Phase 1 — Design (contratos y modelo de presentación)

- **`data-model.md`**: view-data que consumen los componentes (`MediaCardData`: id, posterUrl, title, rating; datos de `DetailHeader`; `PagedMovies`).
- **`contracts/`**: contrato de cada componente del design system (props/callbacks) y de los ViewModels (entradas/estados emitidos) para poder escribir widget tests contra ellos.
- **`quickstart.md`**: pasos para correr la app, verificar el tema y ejecutar los tests.

## Responsabilidades y verificación de calidad

### Agente UI/UX (`movie-ui-ux`) — responsable de la capa visual

El agente UI/UX es el **responsable de verificar** que se cumplan estos criterios antes de dar por cerrada cada pantalla:

1. **Verificación del tema Netflix**: confirmar que toda pantalla usa exclusivamente `AppTheme.dark` y los tokens de `lib/design_system/theme/` (colores, tipografía, espaciados, radios) — sin colores/paddings hardcodeados fuera del design system. Fondo casi negro, acento rojo Netflix `#E50914`, contraste WCAG AA/AAA.
2. **Verificación del design system**: confirmar que las pantallas se construyen **reutilizando** atoms/molecules/organisms existentes (MediaCard, MediaCarousel, DebouncedSearchBar, CatalogSearchAppBar, DetailHeader, EmptyState, ErrorState, RatingBadge, AppChip…) en vez de recrear UI duplicada. Todo componente compartido vive en `lib/design_system/`, no en `features/`.
3. **Verificación de la convención DRY / widgets como clases**: confirmar que **no** existan widgets construidos dentro de métodos privados o públicos (`Widget _buildX(...)`); cada sub-árbol reutilizable/compuesto debe ser su propia clase de widget con `const` constructor cuando aplique. Señalar y refactorizar cualquier violación.
4. **Verificación de estados y accesibilidad**: loading (shimmer), vacío y error presentes en cada pantalla; touch targets ≥ 44dp; textos legibles sobre imágenes (scrims); `Semantics`/tooltips en íconos.
5. **Verificación visual en ejecución**: revisar la app corriendo (o capturas) contra los criterios de éxito SC-004/SC-005/SC-006 de la spec.

Entrega del agente UI/UX en cada iteración: reporte de verificación (qué tokens/componentes se reutilizaron, violaciones DRY encontradas y corregidas, cumplimiento de estados/a11y).

### Code reviewer — gate final

Tras la implementación, el `code-reviewer` valida capas (domain sin imports de data/presentation), MVVM correcto, y ratifica la convención de widgets como clases y el uso del design system.

## Trabajo restante (no cubierto aún)

1. **Refactor `HomeScreen`** → consumir `CatalogSearchAppBar` + `MediaCarousel` para Popular y Top Rated; añadir sección Top Rated (hoy solo Popular) y la barra de búsqueda. Aplicar widgets-como-clases.
2. **ViewModel de búsqueda** con debounce (usecase `SearchMovies`): estados carga/éxito/vacío/error; restaurar catálogo al limpiar.
3. **Pantalla de Detalle** usando `DetailHeader` (usecase `GetMovieDetail` ya existe) + ruta en fluro.
4. **`ApiConfig.backdropUrl()`** para el backdrop del Detalle.
5. **Tests**: unit (debounce, paginación, restauración de vista) + widget (componentes y pantallas). Cubrir los ejemplos del ejercicio (navegación listado↔detalle, scroll en listados/detalle).
6. **Verificación UI/UX** según la sección anterior.

## Complexity Tracking

> Sin violaciones de constitución que justificar.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
