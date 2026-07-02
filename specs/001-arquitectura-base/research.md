# Research: Arquitectura Base (Clean Architecture Scaffold)

**Feature**: `001-arquitectura-base` | **Date**: 2026-07-01

Todas las incógnitas del Technical Context están resueltas. No quedan marcadores `NEEDS CLARIFICATION` (el stack fue impuesto por el usuario y refinado en `/speckit-clarify`).

---

## Decisión 1: State management y DI con Riverpod manual (sin codegen)

- **Decision**: Usar `flutter_riverpod` con providers y Notifiers escritos a mano (sin `riverpod_generator`). El ViewModel es un `Notifier`/`AsyncNotifier` manual expuesto vía su `Provider`.
- **Rationale**: El usuario descartó explícitamente el codegen de Riverpod. El patrón manual es el usado en la referencia `fin/auth_methods` (`AutoDisposeAsyncNotifierProvider`). Riverpod cubre a la vez state management y DI, evitando `get_it`.
- **Alternatives considered**:
  - `riverpod_generator` (`@riverpod`): rechazado por decisión del usuario.
  - `get_it` + `provider`: añade dos dependencias donde Riverpod basta.
- **Versión recomendada**: `flutter_riverpod: ^2.6.1` (API estable de Notifier/AsyncNotifier manual, sin acoplarse a cambios de Riverpod 3.x).

## Decisión 2: Estado de UI — `UIState<T>` genérico, clase sellada en Dart puro (sin Freezed)

- **Decision**: Clase sellada genérica `UIState<T>` **sin Freezed**: una clase madre `sealed class UIState<T>` y subclases `UILoading<T>`, `UISuccess<T>` (con `T data`), `UIFail<T>` (con `Failure failure`). Es el `state` de cada ViewModel.
- **Rationale**: El usuario pidió explícitamente una "clase madre" con subclases que extiendan, sin generación de código. Al ser `sealed` (Dart 3), el `switch` en la UI es exhaustivo por el compilador, evitando estados ad-hoc por feature (como los `bool isLoading` de la referencia fin).
- **Alternatives considered**:
  - `AsyncValue` de Riverpod: válido, pero el usuario pidió una clase propia genérica y control explícito.
  - Estados por feature con flags booleanos (patrón fin): más verboso y propenso a estados inconsistentes.

## Decisión 3: Contrato de resultado — `Result<T>` sellado con Freezed (empty/success/fail)

- **Decision**: Tipo sellado genérico `Result<T>` (Freezed) con variantes `empty`, `success(T data)`, `fail(Failure failure)`. Lo **produce el repositorio** (capa data) al envolver la conversión modelo→entidad; fluye a caso de uso y ViewModel.
- **Rationale**: Manejo de errores explícito y testeable sin excepciones no controladas, sin dependencias externas (no `dartz`/`fpdart`). La variante `empty` modela "sin datos" como estado de primera clase.
- **Alternatives considered**:
  - `Either<Failure,T>` (`dartz`/`fpdart`): añade dependencia y no cubre `empty` nativamente.
  - Excepciones + try/catch: menos explícito para el contrato entre capas.
- **Mapeo a UIState** (en el ViewModel): `success→UIState.success`, `fail→UIState.fail`, `empty→UIState.success` con lista vacía (o estado equivalente).

## Decisión 4: Routing con Fluro

- **Decision**: Un `FluroRouter` global configurado en `lib/navigation/app_router.dart` (fuera de `core`, porque depende de Flutter), con constantes de ruta en `lib/navigation/route_paths.dart`. Cada feature define sus rutas hijas en `presentation/navigation/` y las expone al router global. La app navega a `home` a través del router (no navegación hardcodeada).
- **Rationale**: Requisito del ADR/usuario. Centraliza la definición de rutas y prepara la navegación a `detalle`/`buscador` en features futuras.
- **Versión recomendada**: `fluro: ^2.0.5`.
- **Nota**: La referencia `persefone` usa un `Map<String, WidgetBuilder>`; aquí se usa Fluro real por requisito explícito.

## Decisión 5: Modelado con Freezed 

- **Decision**: `freezed` para la entidad `Movie`, el modelo `MovieModel`, y los tipos sellados `Result<T>` y `Failure`. `build_runner` genera el código (`*.freezed.dart`). **`UIState<T>` NO usa Freezed**: es una clase sellada escrita a mano (ver Decisión 2).
- **Rationale**: Requisito del ADR. Inmutabilidad, `copyWith`, igualdad y uniones selladas gratis.
- **Versión recomendada**: `freezed: ^2.5.7` + `freezed_annotation: ^2.4.4` (compatible con Dart 3.10.7). `json_serializable`/`json_annotation` se dejan como opcionales para cuando se integre la API real (el mock no requiere serialización JSON).
- **Confinamiento del modelo**: `MovieModel` vive solo en `data/`; el repositorio expone `toEntity()` para producir `Movie`. Ni domain ni presentation importan `MovieModel`.

## Decisión 6: Data source mockeado con `await Future`

- **Decision**: `MovieMockDataSource` devuelve `Future<List<MovieModel>>` tras un `Future.delayed` (latencia simulada) con 2-3 películas placeholder. Un flag/parámetro permite simular fallo para ejercitar el camino `fail`.
- **Rationale**: Replica el comportamiento asíncrono real sin acoplar a TMDB; permite sustituir el mock por la implementación HTTP sin reorganizar carpetas.
- **Alternatives considered**: devolver datos síncronos → no ejercita el estado `loading` ni el patrón `async`.

## Decisión 7: Testing con `flutter_test` + `mocktail`

- **Decision**: Pruebas unitarias del caso de uso (`GetMovies`) con un `MovieRepository` mock (mocktail), y del `MovieRepositoryImpl` verificando el mapeo model→entidad y las variantes `Result` (success/empty/fail).
- **Rationale**: Valida la regla de dependencia y el contrato entre capas de forma aislada y rápida.
- **Versión recomendada**: `mocktail: ^1.0.4` (sin codegen, alineado con la decisión de evitar generación de código para mocks).

---

## Dependencias resultantes (para `pubspec.yaml`)

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  freezed_annotation: ^2.4.4
  fluro: ^2.0.5

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  mocktail: ^1.0.4
```

> Las versiones son un punto de partida; se resolverán con `flutter pub add` según lo que publique pub.dev en el momento de implementación.
