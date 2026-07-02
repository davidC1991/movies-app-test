# Feature Specification: Arquitectura Base (Clean Architecture Scaffold)

**Feature Branch**: `001-arquitectura-base`  
**Created**: 2026-07-01  
**Status**: Draft  
**Input**: User description: "Crear la estructura de carpetas que define la arquitectura de la app de Películas/Series, dejando definida la organización folder y el agrupamiento basado en Clean Architecture (capas data, domain y presentation), usando Riverpod, Freezed y Fluro. En la capa de data mockear un servicio con un `await Future` para replicar el comportamiento real, y crear un botón en la pantalla principal que devuelva algo para verificar que toda la base de la arquitectura funcione end-to-end. Aún no se construye la UI real. La inyección de dependencias se hace con Riverpod (referencia: fin auth_methods/providers). Guía de Clean Architecture: persefone lib/features."

## Overview

Esta feature **no entrega funcionalidad de negocio para el usuario final**. Es una base técnica (scaffold) cuyo cliente es el **equipo de desarrollo**. Establece la estructura de carpetas, la separación de capas de Clean Architecture y el cableado de dependencias que soportarán las features reales del ejercicio (categorías Popular/Top Rated, detalle, buscador). El objetivo es demostrar que el flujo completo entre capas funciona antes de invertir en UI o en la integración real con la API de TMDB.

## Clarifications

### Session 2026-07-01

- Q: ¿Qué enfoque de Riverpod usamos en la capa de presentación para el flujo de verificación? → A: MVVM sin codegen de Riverpod. La capa de presentación se organiza con ViewModels (Notifier/AsyncNotifier manuales de Riverpod) que leen el provider donde se inyecta la dependencia (repositorio/caso de uso) vía `ref.read`. El estado de cada ViewModel es una clase genérica **`UIState<T>`** (clase "madre") con variantes loading / success / fail. Guía de referencia: `fin/auth_methods/ui`.
- Q: ¿Cómo debe la capa domain/repositorio comunicar los fallos (para que presentación muestre estado de error)? → A: Un tipo **`Result<T>` sellado generado con Freezed** con **tres variantes: empty / success / fail**, sin dependencias externas (no dartz/fpdart). Lo retorna el **repositorio** (capa data), que es donde se convierte el modelo a la entidad que recibe la capa de dominio; ese `Result<T>` fluye hacia el caso de uso y el ViewModel.
- Q: ¿La feature inicial que demuestra el flujo end-to-end es 'home' o una feature dedicada de verificación? → A: Feature **`home`** (`lib/features/home`), reutilizable como pantalla real de la app más adelante (no una feature desechable).
- Q: ¿Qué devuelve concretamente el flujo de verificación (el dato que produce el mock y muestra el botón)? → A: Una **lista de películas placeholder** (`List<Movie>` con 2-3 entidades `Movie` simuladas: id, title), ejercitando Freezed y el mapeo modelo→entidad.
- Q: ¿El camino de error (estado fail) debe demostrarse o solo soportarse? → A: El **repositorio** (capa data) devuelve el `Result<T>` tras convertir modelo→entidad y puede resolver en **empty, fail o success**; estas variantes se soportan en el contrato y se cubren con pruebas unitarias.
- Q: ¿Qué recibe la capa de presentación y hasta dónde viaja el modelo de datos? → A: El ViewModel **invoca el caso de uso** (capa domain) y recibe la **entidad** (`Movie`), nunca el modelo de datos.

### Session 2026-07-01 — Refinamientos de implementación

Durante la implementación el diseño evolucionó. Estos acuerdos **sustituyen** decisiones previas de esta spec donde haya conflicto:

- **Se elimina `Result<T>` y `Failure`.** El manejo de error/estado de datos se hace con **`ApiResponse<T>`** en la capa data (variantes `SuccessApiResponse` / `EmptyApiResponse` / `ErrorApiResponse`), producido por un **`ApiResponseHandlerMixin`** (en `core/api/remote/`) que envuelve las llamadas de red y traduce `DioException`/status codes.
- **El domain recibe la entidad libre.** El repositorio usa los callbacks de `ApiResponse` (`when(onSuccess/onEmpty/onError)`) y devuelve `List<Movie>` (puede ser vacía = "empty success"); en error **lanza**. El **ViewModel** maneja el error con **try/catch** y expone `UIState`.
- **`UIState<T>` NO usa Freezed**: es una clase sellada en Dart puro (clase madre + subclases `UILoading`/`UISuccess`/`UIFail`); `UIFail` transporta un `String message`.
- **`MovieModel extends Movie` (principio de sustitución de Liskov).** Un `MovieModel` *es un* `Movie`, por lo que el repositorio lo devuelve **directamente como entidad** sin mapeo manual. Por eso `Movie` es una clase plana con **Equatable** (no Freezed, para poder ser extendida) y `MovieModel` usa **json_serializable** (no Freezed).
- **Data source y repositorio se dividen en abstracto + implementación remota**: `MovieDataSource`/`MovieDataSourceRemote` y `MovieRepository`/`MovieRepositoryRemote`.
- **Cliente HTTP autogenerado con retrofit**: `MovieService` (`@RestApi`) con los endpoints de TMDB; el `MovieDataSourceRemote` solo lo inyecta. El `Dio` compartido y su config (base URL, token) viven en `core/api/`.
- **El mock queda como respuesta simulada dentro del `MovieDataSourceRemote`** (con la llamada real de retrofit comentada, lista para activar con `--dart-define=TMDB_TOKEN=...`).
- **Las pruebas unitarias quedan temporalmente desactivadas** (movidas a `test_disabled/`) por decisión de priorización.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verificar el flujo end-to-end de la arquitectura (Priority: P1)

Como desarrollador, quiero pulsar un botón en la pantalla principal y ver un valor que viajó a través de todas las capas (presentation → domain → data → mock service → y de vuelta), para confirmar que la separación de capas y la inyección de dependencias con Riverpod están correctamente cableadas.

**Why this priority**: Es la razón de ser de la feature. Sin esta verificación end-to-end no hay evidencia de que la base arquitectónica sea correcta, y todo el trabajo posterior se construiría sobre un cimiento no validado.

**Independent Test**: Ejecutar la app, pulsar el botón de la pantalla principal y observar que se muestra el valor devuelto por el servicio mockeado (tras la resolución del `Future`), confirmando que el dato atravesó las tres capas.

**Acceptance Scenarios**:

1. **Given** la app en la pantalla principal con la arquitectura cableada, **When** el desarrollador pulsa el botón de verificación, **Then** la app invoca un caso de uso del dominio que a través del repositorio consume el data source mockeado y muestra el resultado en pantalla.
2. **Given** el data source mockeado que simula latencia con `await Future`, **When** se dispara la petición, **Then** la UI refleja el estado de carga mientras el `Future` está pendiente y el estado de éxito cuando resuelve.
3. **Given** las dependencias declaradas como providers de Riverpod, **When** la capa de presentación solicita el caso de uso, **Then** Riverpod resuelve la cadena completa (data source → repositorio → caso de uso) sin instanciación manual.

---

### User Story 2 - Disponer de una estructura de carpetas escalable y consistente (Priority: P2)

Como desarrollador, quiero que exista una estructura de carpetas por feature con las tres capas de Clean Architecture claramente separadas, para poder añadir nuevas features (listados, detalle, buscador) replicando el mismo patrón sin ambigüedad.

**Why this priority**: La escalabilidad es un requisito explícito del ejercicio. Una estructura consistente reduce la fricción de las siguientes features, pero depende de que el flujo base (P1) exista primero.

**Independent Test**: Revisar el árbol de `lib/` y comprobar que cada feature contiene las carpetas `data`, `domain` y `presentation` con sus subcarpetas convencionales, y que existe una capa `core` compartida.

**Acceptance Scenarios**:

1. **Given** el proyecto, **When** se inspecciona la carpeta de una feature, **Then** contiene subcarpetas para data (datasource, repository, model), domain (entity, repository, usecases) y presentation (providers/notifiers, ui).
2. **Given** el proyecto, **When** se inspecciona `lib/core`, **Then** contiene los elementos transversales (navegación/routing, errores, inyección de dependencias/providers globales, utilidades).

---

### User Story 3 - Dependencias de routing y modelado configuradas (Priority: P3)

Como desarrollador, quiero que Fluro (routing) y Freezed (modelado inmutable) estén configurados y demostrados de forma mínima, para que las siguientes features los usen sin trabajo de setup adicional.

**Why this priority**: Deja la base lista pero no bloquea la validación del flujo; puede completarse tras P1 y P2.

**Independent Test**: Comprobar que el router de Fluro registra al menos la ruta de la pantalla principal y que existe al menos un modelo/entidad generado con Freezed usado en el flujo de verificación.

**Acceptance Scenarios**:

1. **Given** el router configurado con Fluro, **When** la app arranca, **Then** navega a la pantalla principal a través del router (no mediante navegación hardcodeada).
2. **Given** un modelo Freezed, **When** el data source mockeado devuelve datos, **Then** estos se representan con una clase inmutable generada por Freezed.

---

### Edge Cases

- ¿Qué ocurre si el servicio mockeado se configura para fallar? La cadena debe propagar el error hasta un estado de error observable en presentación (no un crash sin manejar).
- ¿Qué ocurre mientras el `Future` está pendiente? La presentación debe exponer un estado de carga distinguible del estado de éxito y del de error.
- ¿Cómo se evita el acoplamiento entre capas? La capa de domain no debe importar nada de data ni de presentation; las dependencias apuntan hacia adentro (regla de dependencia de Clean Architecture).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El proyecto MUST organizar el código bajo un enfoque de Clean Architecture con tres capas explícitas: **data**, **domain** y **presentation**, agrupadas por feature.
- **FR-002**: El proyecto MUST incluir una capa **core** compartida para elementos transversales (routing/navegación, manejo de errores, inyección de dependencias global, utilidades).
- **FR-003**: La capa **domain** MUST ser independiente de las capas data y presentation (sin imports hacia ellas), conteniendo entidades, contratos de repositorio (abstracciones) y casos de uso.
- **FR-004**: La capa **data** MUST exponer un data source dividido en **contrato abstracto (`MovieDataSource`)** e **implementación remota (`MovieDataSourceRemote`)**. La implementación inyecta un cliente HTTP autogenerado (retrofit `MovieService`) y devuelve `Future<ApiResponse<List<MovieModel>>>`. Por ahora la respuesta está **simulada** (mock con `await Future` dentro del remoto), con la llamada real a TMDB comentada y lista para activar.
- **FR-004a**: El envoltorio de respuesta de red MUST ser **`ApiResponse<T>`** (variantes `SuccessApiResponse` / `EmptyApiResponse` / `ErrorApiResponse`), producido por un **`ApiResponseHandlerMixin`** (en `core/api/remote/`) que traduce `DioException` y status codes a esas variantes.
- **FR-005**: La capa **data** MUST implementar los contratos de repositorio (`MovieRepository` → `MovieRepositoryRemote`), al que se le **inyecta el `MovieDataSource` abstracto**. El repositorio usa los callbacks de `ApiResponse` (`when(onSuccess/onEmpty/onError)`) para decidir qué entrega al domain.
- **FR-005a**: El domain MUST recibir la **entidad libre** (`List<Movie>`, que puede venir vacía = "empty success"). En caso de error el repositorio **lanza** (no usa tipos `Result`/`Failure`); la capa de presentación maneja el error con **try/catch**.
- **FR-006**: La inyección de dependencias MUST realizarse mediante **providers de Riverpod escritos manualmente (sin codegen de Riverpod)**, ensamblando la cadena `Dio` (core) → data source → repositorio → caso de uso (referencia: `fin/auth_methods/providers`).
- **FR-006a**: La capa **presentation** MUST organizarse siguiendo **MVVM**: cada pantalla/flujo tiene un **ViewModel** (Notifier manual de Riverpod) que **invoca el caso de uso** vía `ref.read`, recibe la **entidad de dominio** y expone `UIState<T>` a la UI, envolviendo la invocación en try/catch. Referencia: `fin/auth_methods/ui`.
- **FR-006b**: El estado expuesto por cada ViewModel MUST representarse con una clase sellada genérica **`UIState<T>`** en **Dart puro (sin Freezed)** — clase madre + subclases `UILoading` / `UISuccess(data)` / `UIFail(message)`.
- **FR-006c**: El **`MovieModel` MUST permanecer confinado a la capa data** (no se importa fuera de `data/`). Al **extender la entidad `Movie`** (LSP), el repositorio puede devolverlo directamente como `Movie` sin exponer el tipo del modelo.
- **FR-007**: El modelado MUST usar **generación de código donde aporte**: `MovieModel`/`MovieResponseModel` usan **json_serializable** para `fromJson`/`toJson`; el cliente REST usa **retrofit** (`retrofit_generator`). La entidad `Movie` es una clase plana con **Equatable** (para poder ser extendida por el modelo).
- **FR-008**: La navegación MUST configurarse con **Fluro**: un router global en `lib/navigation/` que agrega las rutas que cada feature expone desde su `presentation/navigation/`; registra al menos la ruta de `home`.
- **FR-009**: La pantalla principal MUST incluir un **botón de verificación** que dispare el flujo completo a través de las tres capas y muestre el resultado (lista de películas o, según el estado, vacío/error).
- **FR-010**: La presentación MUST exponer estados observables de **carga, éxito y error** mediante `UIState<T>` (loading / success / fail) en el ViewModel.
- **FR-011**: El proyecto MUST contar con **pruebas unitarias** del flujo domain/data (caso de uso y repositorio con dobles del data source, cubriendo success/empty/error). *(Actualmente desactivadas en `test_disabled/` por priorización; reactivables sin cambios.)*
- **FR-012**: La solución MUST evitar la construcción de UI final/definitiva; la pantalla principal es únicamente un arnés de verificación mínimo.

### Key Entities *(include if feature involves data)*

- **`Movie` (domain, placeholder)**: Entidad de dominio mínima (`id`, `title`), **clase plana con Equatable** (no Freezed, para poder ser extendida por el modelo). Se ampliará en features reales.
- **`MovieModel` (data)**: Modelo de datos que **extiende `Movie`** (LSP) y añade `fromJson`/`toJson` (json_serializable). **Confinado a la capa data**; al ser-un `Movie`, el repositorio lo devuelve directamente como entidad.
- **`MovieResponseModel` (data)**: Envoltura paginada de TMDB (`page`, `results: List<MovieModel>`), generada con Freezed + json_serializable.
- **`MovieService` (data/api)**: Cliente REST **autogenerado con retrofit** (`@RestApi`) con los endpoints TMDB (popular, top_rated, detalle, búsqueda). Recibe `Dio` y `baseUrl`.
- **`MovieDataSource` / `MovieDataSourceRemote` (data)**: Contrato abstracto e implementación remota que inyecta `MovieService`, usa `ApiResponseHandlerMixin` y devuelve `ApiResponse<List<MovieModel>>`.
- **`MovieRepository` / `MovieRepositoryRemote` (domain/data)**: Contrato que devuelve `Future<List<Movie>>` e implementación que inyecta el `MovieDataSource`, mapea `ApiResponse` a entidad (o lanza en error).
- **`ApiResponse<T>` (core/api)**: Unión sellada con `SuccessApiResponse(body)` / `EmptyApiResponse` / `ErrorApiResponse(httpErrorMessage, httpStatusCode)`. `ErrorApiResponse` implementa `Exception`.
- **`ApiResponseHandlerMixin` (core/api)**: Mixin que ejecuta la llamada de red y la traduce a `ApiResponse<T>` (maneja `DioException`, timeouts, status codes).
- **`UIState<T>` (presentation)**: Clase sellada en Dart puro (sin Freezed) con `UILoading` / `UISuccess(data)` / `UIFail(message)`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Al pulsar el botón de la pantalla principal, el 100% de las veces se muestra el valor devuelto por el servicio mockeado tras resolverse el `Future`.
- **SC-002**: Un desarrollador puede identificar en qué carpeta colocar un nuevo archivo (data/domain/presentation/core) en menos de 30 segundos inspeccionando la estructura, sin documentación adicional.
- **SC-003**: La capa de dominio no contiene ninguna dependencia hacia data ni presentation (verificable por inspección de imports: 0 violaciones).
- **SC-004**: Toda la cadena de dependencias del flujo de verificación se resuelve vía Riverpod sin ninguna instanciación manual de repositorios o data sources en la capa de presentación.
- **SC-004a**: El `MovieModel` no aparece importado fuera de la capa data, y el domain/presentation solo manejan la entidad `Movie` (verificable por inspección de imports: 0 violaciones).
- **SC-005**: Existen pruebas unitarias del flujo domain/data (success/empty/error). *(Temporalmente desactivadas en `test_disabled/`.)*
- **SC-006**: El proyecto compila y arranca navegando a `home` vía Fluro, sin errores de análisis (`flutter analyze` sin errores; solo quedan `info` de estilo en código de terceros/mixin).

## Assumptions

- **Stack tecnológico**: Flutter/Dart (≥ 3.35.7 según el ADR), Riverpod (state management + DI manual), Freezed + json_serializable (modelado/serialización), Fluro (routing), dio + retrofit (HTTP tipado autogenerado), Equatable (igualdad de valor). Estas elecciones son requisitos base del ejercicio y refinamientos acordados.
- **La API real de TMDB queda fuera de alcance activo** en esta feature; el `MovieDataSourceRemote` devuelve datos simulados con la llamada real de retrofit comentada. Activarla es descomentar el bloque y pasar `--dart-define=TMDB_TOKEN=...`, sin reorganizar carpetas.
- **La UI definitiva queda fuera de alcance**; la pantalla principal es solo un arnés de verificación con un botón.
- **Patrón de organización**: agrupamiento por feature con capas internas data/domain/presentation, más una carpeta `core` compartida, tomando como guía la estructura de `persefone/lib/features` (adaptando el manejo de estado de Cubit a Riverpod).
- **Patrón de DI**: providers de Riverpod **manuales (sin codegen)** que ensamblan la cadena data source → repositorio → caso de uso, tomando como referencia `fin/auth_methods/providers/auth_provider.dart`.
- **Patrón de presentación (MVVM)**: ViewModels (Notifier/AsyncNotifier manuales) que leen los providers de DI y exponen `UIState<T>`, tomando como referencia `fin/auth_methods/ui`.
- **La feature inicial es `home`** (`lib/features/home`), con las tres capas y el botón de verificación; es reutilizable como pantalla real más adelante. El resto de features (listados Popular/Top Rated, detalle, buscador) se añadirán en trabajo posterior replicando el patrón.
