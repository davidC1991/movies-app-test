# Feature Specification: Consumo real de películas (TMDB)

**Feature Branch**: `002-tmdb-peliculas-reales`  
**Created**: 2026-07-01  
**Status**: Draft  
**Input**: User description: "Consumir los servicios de movie de manera real (API de TMDB). En las capas data y domain crear los casos de uso para que el ViewModel pueda llamarlos sin problema. La lista que se ve en la UI debe mostrar las películas reales del servicio. Hay pasos manuales (cuenta/token TMDB) que el usuario realizará."

## Overview

Reemplazar los datos simulados por **datos reales de TMDB**. Sobre la base arquitectónica ya existente (`001-arquitectura-base`), esta feature conecta el `MovieService` (retrofit) real y define en data/domain **un caso de uso por cada operación que el ejercicio requiere** (Popular, Top Rated, Detalle, Búsqueda), de modo que los ViewModels puedan invocarlos sin problema. La **pantalla principal muestra las películas reales** (listado Popular con scroll infinito) con sus estados de carga, éxito, vacío y error; el resto de operaciones queda cableado end-to-end como casos de uso, listos para sus pantallas en features posteriores.

Requiere un **paso manual del usuario**: crear una cuenta en TMDB y generar el token de acceso (documentado en la guía del ejercicio), que se inyectará en tiempo de ejecución.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ver películas reales en el listado (Priority: P1)

Como usuario de la app, quiero abrir la pantalla principal y ver un listado de películas reales obtenidas del servicio (TMDB), para explorar el catálogo actual en lugar de datos de prueba.

**Why this priority**: Es el objetivo central de la feature: sustituir el mock por datos reales; sin esto no hay valor para el usuario final.

**Independent Test**: Con el token configurado, abrir la app y confirmar que el listado muestra títulos reales de TMDB (que cambian con el catálogo), no las 3 películas placeholder.

**Acceptance Scenarios**:

1. **Given** la app con el token de TMDB configurado, **When** se abre la pantalla principal, **Then** se dispara la petición al servicio y se muestra el listado de películas reales.
2. **Given** la petición en curso, **When** los datos aún no llegan, **Then** la UI muestra un indicador de carga.
3. **Given** una respuesta exitosa con películas, **When** se renderiza, **Then** cada ítem muestra la información de la película (al menos su título).
4. **Given** una respuesta exitosa sin resultados, **When** se renderiza, **Then** la UI muestra un estado vacío claro (no una lista en blanco ambigua).

---

### User Story 2 - Manejo de errores de red/servicio (Priority: P2)

Como usuario, quiero que si el servicio falla (sin red, token inválido, error del servidor) la app me muestre un mensaje claro en vez de quedarse cargando o crashear, para entender qué pasó y poder reintentar.

**Why this priority**: La robustez ante fallos de red es esencial para una app que depende de un servicio externo, pero es secundaria a mostrar el listado feliz.

**Independent Test**: Ejecutar sin token (o sin red) y confirmar que se muestra un estado de error legible con opción de reintentar.

**Acceptance Scenarios**:

1. **Given** el servicio devuelve un error (p. ej. 401 por token inválido o sin conexión), **When** se procesa la respuesta, **Then** la UI muestra un mensaje de error comprensible.
2. **Given** la UI en estado de error, **When** el usuario reintenta, **Then** se vuelve a disparar la petición.

---

### User Story 3 - Casos de uso disponibles para la presentación (Priority: P2)

Como desarrollador, quiero **un caso de uso por cada operación del catálogo** (populares, top rated, detalle, búsqueda) que el ViewModel pueda invocar directamente, para mantener la lógica de negocio desacoplada de la UI y del origen de datos, y habilitar las features siguientes reutilizando el patrón.

**Why this priority**: Habilita esta feature y las siguientes (top rated, detalle, buscador) con el mismo flujo; es transversal al valor de US1/US2.

**Independent Test**: Verificar que existen los 4 casos de uso, que el ViewModel del listado invoca el de populares, y que cada uno devuelve entidades de dominio a partir del servicio real.

**Acceptance Scenarios**:

1. **Given** el ViewModel, **When** solicita las películas, **Then** invoca un caso de uso del dominio (no accede al servicio ni al repositorio directamente para la lógica).
2. **Given** cada caso de uso (populares/top rated/detalle/búsqueda), **When** se ejecuta, **Then** devuelve entidades de dominio con los datos reales mapeados desde la respuesta del servicio.
3. **Given** el repositorio, **When** un caso de uso lo invoca, **Then** existe el método correspondiente que consume el endpoint TMDB adecuado y mapea la respuesta.

---

### Edge Cases

- **Token ausente o inválido**: la app debe mostrar error legible (no pantalla en blanco ni crash). El token se lee de un archivo `.env` (variable de entorno); si falta, la app muestra estado de error.
- **Sin conexión / timeout**: estado de error con posibilidad de reintento.
- **Respuesta vacía**: estado vacío distinguible del estado de carga.
- **Imágenes de póster faltantes**: placeholder visual en lugar de romper el layout.
- **Paginación**: al hacer scroll al final del listado se cargan más páginas (scroll infinito); mientras carga la siguiente página se muestra un indicador al pie; si la carga de la página siguiente falla, se puede reintentar sin perder lo ya cargado.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema MUST obtener el listado de películas **Popular** desde el servicio real de TMDB, reemplazando los datos simulados, y mostrarlo en la pantalla principal.
- **FR-002**: La capa **domain** MUST exponer **un caso de uso por cada operación requerida** — `GetPopularMovies`, `GetTopRatedMovies`, `GetMovieDetail`, `SearchMovies` — que la presentación invoca; el ViewModel no accede al repositorio/servicio directamente para la lógica de negocio. Cada caso de uso tiene su método correspondiente en el repositorio y el data source.
- **FR-003**: La capa **data** MUST consumir el servicio real y **mapear la respuesta a entidades de dominio**, manteniendo el modelo confinado a data.
- **FR-004**: La **pantalla principal** MUST mostrar el listado de películas reales, con estados observables de **carga, éxito, vacío y error**.
- **FR-005**: Cada ítem del listado MUST mostrar el **póster**, el **título** y la **calificación (rating)** de la película. La entidad de dominio se amplía con los campos necesarios (póster y calificación).
- **FR-006**: El sistema MUST manejar los fallos del servicio (sin red, token inválido, error del servidor) mostrando un **mensaje de error comprensible**, sin crashear.
- **FR-007**: La UI en estado de error MUST ofrecer una acción de **reintento**.
- **FR-008**: La autenticación MUST usar el **Read Access Token estático** de TMDB (Bearer), suficiente para los endpoints de lectura requeridos. Este token MUST leerse de un archivo **`.env`** (fuera del control de versiones); no debe estar incrustado en el código fuente. NO se implementa el flujo de `session_id` (solo aplica a acciones de usuario que este ejercicio no requiere).
- **FR-009**: El sistema MUST realizar la petición al abrir la pantalla (carga automática), sin requerir que el usuario pulse un botón para el flujo normal.
- **FR-010**: La solución MUST reutilizar la arquitectura existente (Clean Architecture + MVVM + ApiResponse + retrofit) sin reorganizar la estructura de carpetas.
- **FR-011**: El listado Popular MUST soportar **paginación con scroll infinito**: al aproximarse al final, carga la siguiente página y la anexa a los resultados; muestra un indicador de carga de página y permite reintentar si falla, sin perder lo ya cargado.
- **FR-012**: El sistema MUST exponer la operación **Top Rated** (listado paginado) como caso de uso y método de repositorio/data source, reutilizable por su pantalla en una feature posterior.
- **FR-013**: El sistema MUST exponer la operación **Detalle de película** (por identificador) como caso de uso y método de repositorio/data source, devolviendo una entidad de detalle.
- **FR-014**: El sistema MUST exponer la operación **Búsqueda por nombre** (paginada) como caso de uso y método de repositorio/data source.
- **FR-015**: Las rutas de imagen (póster) MUST componerse con el **base URL de imágenes** del servicio para poder mostrarse; los pósters faltantes usan un placeholder.

### Operaciones del servicio requeridas (mapeo requerimiento → operación)

| Requerimiento (ejercicio) | Operación del servicio | Caso de uso | Estado en esta feature |
|---------------------------|------------------------|-------------|------------------------|
| Listado Popular | `movie/popular` (paginado) | `GetPopularMovies` | Con UI (pantalla principal) |
| Listado Top Rated | `movie/top_rated` (paginado) | `GetTopRatedMovies` | Cableado (UI posterior) |
| Detalle de película | `movie/{id}` | `GetMovieDetail` | Cableado (UI posterior) |
| Buscador por nombre | `search/movie` (paginado) | `SearchMovies` | Cableado (UI posterior) |

### Key Entities *(include if feature involves data)*

- **Película (Movie)**: Entidad de dominio de un ítem del catálogo. Atributos: identificador, título, **póster** (ruta de imagen) y **calificación** (rating). Se amplía respecto a la base (id, title).
- **Detalle de película (MovieDetail)**: Entidad con la información ampliada de una película (además de lo anterior: sinopsis, fecha de estreno, duración, géneros). Devuelta por la operación de detalle.
- **Listado paginado de películas**: Colección de películas de una categoría (Popular/Top Rated) con información de paginación (página actual y si hay más páginas) para el scroll infinito.
- **Resultado de búsqueda**: Listado paginado de películas que coinciden con un término de búsqueda.
- **Configuración de acceso (token TMDB)**: Credencial requerida para autenticar las peticiones, leída de un archivo `.env`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Con el token configurado, la pantalla principal muestra películas reales de TMDB en el **100%** de los arranques con conexión válida.
- **SC-002**: Los títulos mostrados corresponden a los devueltos por el servicio (verificable comparando con la respuesta del endpoint), no a los 3 placeholder previos.
- **SC-003**: Ante un fallo del servicio, el usuario ve un mensaje de error legible sin crash ni pantalla en blanco.
- **SC-004**: El usuario percibe el resultado (lista o error) en un tiempo acorde a una petición de red estándar (típicamente < 3 s en condiciones normales).
- **SC-005**: El ViewModel obtiene los datos exclusivamente a través de un caso de uso del dominio (verificable: la presentación no referencia el servicio/repositorio para la lógica).
- **SC-006**: Existen los **4 casos de uso** (populares, top rated, detalle, búsqueda) invocables desde presentación, cada uno con su método en repositorio y data source que consume el endpoint TMDB correspondiente.
- **SC-007**: Al hacer scroll al final del listado Popular, se cargan y anexan más películas (segunda página en adelante) sin perder las ya mostradas.

## Assumptions

- **Paso manual del usuario**: crear cuenta en TMDB, copiar el **API Read Access Token** (Bearer, estático, no expira) desde *Settings → API*, y **crear un archivo `.env`** en la raíz con la variable del token (p. ej. `TMDB_TOKEN=...`). El `.env` queda fuera del control de versiones. Sin token válido, la app mostrará el estado de error (esperado).
- **Autenticación**: se usa el Read Access Token estático (Bearer) para los endpoints de lectura. El **flujo de `session_id`** (request_token → aprobación en navegador → session_id) queda **fuera de alcance**: solo aplica a acciones de usuario (calificar/favoritos/watchlist) que este ejercicio no requiere. El ejercicio enlaza esa página de autenticación como puntero a dónde obtener credenciales y ver las colecciones de endpoints, no como requisito de implementar sesión.
- **Alcance de UI vs cableado**: la **UI** de esta feature es el listado **Popular** (visible, con scroll infinito). Las operaciones **Top Rated, Detalle y Búsqueda** se dejan **cableadas end-to-end como casos de uso** (data → domain), pero sus **pantallas** son features posteriores.
- **Endpoints TMDB (v3)**: base `https://api.themoviedb.org/3`; `movie/popular`, `movie/top_rated`, `movie/{id}`, `search/movie`. Imágenes de póster vía `https://image.tmdb.org/t/p/{size}{poster_path}`.
- **Base arquitectónica**: se reutiliza `001-arquitectura-base` (cliente retrofit `MovieService`, `ApiResponse`, MVVM/`UIState`, DI con Riverpod). Ya está cableado; esta feature activa la llamada real y amplía casos de uso/entidad según necesidad.
- **Idioma/región de resultados**: se asume el idioma por defecto del servicio; la localización de resultados queda fuera de alcance.
