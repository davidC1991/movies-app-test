# Movies / Series

App móvil (Flutter) para el ejercicio técnico de Películas/Series. Este repositorio
contiene, por ahora, la **base arquitectónica** (scaffold) verificada end-to-end.

## Stack

- **Flutter 3.38.6 / Dart 3.10.7**
- **flutter_riverpod** — state management + inyección de dependencias (manual, sin codegen)
- **freezed** — modelado inmutable y uniones selladas (`build_runner` para generación)
- **fluro** — routing / navegación
- **flutter_test + mocktail** — pruebas unitarias

## Arquitectura

**Clean Architecture** organizada *feature-first*, con MVVM en la capa de presentación.
La regla de dependencia apunta hacia adentro: `presentation → domain ← data`.

```text
lib/
├── main.dart                 # Entry: setup del router + ProviderScope
├── app.dart                  # MaterialApp con el FluroRouter global
├── navigation/               # Routing global (Fluro) — fuera de core (depende de Flutter)
├── core/                     # Lógica Dart pura (sin Flutter): Result<T>, UIState<T>, Failure
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

La pantalla principal (**Populares**) carga automáticamente las películas reales de
TMDB (póster + título + rating) con **scroll infinito**; ante un fallo muestra un
mensaje con botón **Reintentar**.

## Pruebas

```bash
flutter test
```

Cubren el caso de uso y el repositorio (variantes `Result`: success/empty/fail) y un
smoke test del flujo de la pantalla.

## Estado / pendiente

Esta entrega establece únicamente la base arquitectónica. Pendiente (features reales):
listados Popular/Top Rated, detalle, buscador, e integración real con la API de TMDB
(sustituyendo el `MovieMockDataSource` por una implementación HTTP, sin reorganizar carpetas).

## Uso de IA

La estructura, el modelado y los artefactos de especificación (`specs/001-arquitectura-base/`)
se generaron con asistencia de IA (Claude Code) mediante el flujo Spec Kit
(`/speckit-specify` → `/clarify` → `/plan` → `/tasks` → `/analyze` → `/implement`),
con revisión y decisiones de diseño validadas manualmente.
