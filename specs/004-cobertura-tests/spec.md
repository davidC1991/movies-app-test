# Feature Specification: Cobertura de pruebas unitarias e integración

**Feature Branch**: `004-cobertura-tests`
**Created**: 2026-07-01
**Status**: Draft
**Input**: User description: "Crear la cobertura de tests unitarios y pruebas de integración usando el driver de Flutter; usar mockito para mockear los providers/repository; los tests de los ViewModels de los providers deben verificar los cambios de estado (loading → success/error) escuchando el estado con el patrón `container.listen(provider, (prev, next) {...}, fireImmediately: true)`, como en el ejemplo `fetchCifsBco`."

## Clarifications

### Session 2026-07-01

- Q: ¿Migrar a mockito o convivir con la librería de dobles actual (mocktail)? → A: Migrar totalmente a **mockito** y **reescribir** los tests existentes; se retira mocktail del proyecto.
- Q: ¿Qué se hace con los widget tests actuales (mocktail)? → A: **Eliminarlos**; esos flujos (catálogo, búsqueda, detalle, navegación) se cubren mediante las pruebas de **integración** con el driver de Flutter. Se conservan solo pruebas **unitarias** (ViewModels) + **integración**.
- Q: ¿Umbral numérico de cobertura o solo por comportamiento? → A: Añadir umbral numérico **≥80% de líneas** como criterio de éxito (además de la cobertura por comportamiento), con reporte `flutter test --coverage`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verificar los cambios de estado de los ViewModels (Priority: P1)

Como desarrollador que mantiene la app, quiero pruebas unitarias que verifiquen que cada ViewModel emite la **secuencia correcta de estados** (carga → éxito, y carga → error) ante datos simulados, para detectar regresiones en la lógica de presentación sin depender de la red real.

**Why this priority**: Es el núcleo del pedido y lo que da confianza sobre la lógica de estado (paginación, búsqueda, detalle). Aporta valor por sí sola aunque no existieran las pruebas de integración.

**Independent Test**: Ejecutar la suite unitaria con el repositorio simulado y comprobar que, para cada ViewModel, se observan las transiciones de estado esperadas (incluyendo el estado de carga inicial) y los datos de éxito coinciden con los simulados.

**Acceptance Scenarios**:

1. **Given** un repositorio simulado que devuelve datos válidos, **When** se ejecuta la operación del ViewModel (catálogo/búsqueda/detalle), **Then** el observador del estado ve primero el estado de **carga** y luego el de **éxito** con los datos simulados.
2. **Given** un repositorio simulado que falla, **When** se ejecuta la operación, **Then** el observador ve el estado de **carga** y luego el de **error**, y nunca un éxito.
3. **Given** una prueba que escucha el estado del provider desde su creación, **When** se suscribe con emisión inmediata, **Then** recibe el estado inicial y cada transición posterior sin perder ninguna.

---

### User Story 2 - Cobertura unitaria del catálogo, búsqueda y detalle (Priority: P1)

Como desarrollador, quiero que las reglas de negocio de presentación ya existentes queden cubiertas por pruebas: paginación por categoría, debounce/encadenamiento de búsqueda, restauración del catálogo al limpiar, y carga/reintento del detalle.

**Why this priority**: Sin cubrir estos comportamientos, los cambios futuros pueden romper funcionalidad crítica silenciosamente. Es requisito explícito del ejercicio ("Pruebas Unitarias").

**Independent Test**: Ejecutar la suite y comprobar que existen casos que cubren: cargar Popular + Top Rated, anexar la siguiente página, no paginar sin más páginas, no re-lanzar peticiones tras un error de paginación, búsqueda con/sin resultados, término en blanco = sin búsqueda, prevalece el último término, restaurar al limpiar, y detalle éxito/error.

**Acceptance Scenarios**:

1. **Given** el ViewModel del catálogo, **When** se solicita la siguiente página de una categoría, **Then** los resultados se anexan a los ya cargados y no se duplican peticiones.
2. **Given** una búsqueda en curso, **When** cambia el término antes de que responda, **Then** prevalece el resultado del último término.
3. **Given** una búsqueda con texto en blanco, **When** se ejecuta, **Then** se restaura el catálogo por defecto y no se realiza petición.

---

### User Story 3 - Pruebas de integración de los flujos principales (Priority: P2)

Como desarrollador, quiero pruebas de integración que ejerciten la app real (sobre el driver de Flutter) en los recorridos clave —ver el catálogo, buscar y navegar al detalle y volver— con los datos simulados, para validar que las pantallas y la navegación funcionan de extremo a extremo.

**Why this priority**: Complementa las unitarias verificando la integración UI+navegación; el ejercicio menciona explícitamente pruebas "entre un listado y un detalle" y "al hacer scroll".

**Independent Test**: Lanzar la app de prueba con dependencias simuladas y ejecutar el flujo: aparece el catálogo → se busca un término → se pulsa un resultado → se abre el detalle → se vuelve al catálogo; cada paso se verifica por los elementos visibles.

**Acceptance Scenarios**:

1. **Given** la app arrancada con datos simulados, **When** carga la pantalla principal, **Then** se muestran las categorías con sus ítems.
2. **Given** la pantalla principal, **When** se escribe un término y se pulsa un resultado, **Then** se abre el detalle correspondiente y se puede volver a la lista.
3. **Given** un listado con varias páginas, **When** se hace scroll hasta el final, **Then** se cargan más elementos.

---

### Edge Cases

- **Estado de carga inicial**: las pruebas deben capturar el estado de carga que se emite al construir el ViewModel (suscripción con emisión inmediata), no solo el estado final.
- **Sin emisión de error en el camino feliz**: en el escenario de éxito, la prueba debe fallar si aparece un estado de error.
- **Dependencias externas**: ninguna prueba debe depender de la red real ni de credenciales; todo el acceso a datos se simula.
- **Determinismo**: las pruebas con temporización (debounce) deben ser deterministas (control del tiempo/avance de reloj), sin esperas arbitrarias.
- **Aislamiento**: cada prueba parte de un estado limpio (contenedor/dependencias recreados) para no filtrar estado entre casos.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La suite MUST incluir pruebas **unitarias** de cada ViewModel de presentación (catálogo, búsqueda, detalle) que verifiquen las **transiciones de estado** (carga → éxito y carga → error).
- **FR-002**: Las pruebas de ViewModel MUST observar el estado del provider **suscribiéndose a sus cambios con emisión inmediata**, y aseverar cada estado observado (carga, éxito con datos, error), fallando si aparece un estado no esperado en el camino feliz.
- **FR-003**: El acceso a datos (repositorio/casos de uso) MUST estar **simulado** en las pruebas unitarias; ninguna prueba realiza peticiones reales.
- **FR-004**: La suite MUST cubrir las reglas de negocio de presentación ya existentes: paginación por categoría, no paginar sin más páginas, no re-lanzar peticiones tras error de paginación, búsqueda con/sin resultados, término en blanco = sin búsqueda, prevalece el último término, restauración al limpiar, y detalle éxito/error.
- **FR-005**: La suite MUST incluir pruebas de **integración** que ejerciten la app real en los recorridos principales: ver catálogo, buscar, navegar a detalle y volver, y cargar más al hacer scroll.
- **FR-006**: Las pruebas de integración MUST ejecutarse con **dependencias simuladas** (sin red real) para ser reproducibles.
- **FR-007**: Las pruebas con comportamiento temporal (debounce) MUST ser deterministas (control explícito del avance del tiempo), sin esperas arbitrarias.
- **FR-008**: Cada prueba MUST ser independiente y partir de un estado limpio (sin filtrar estado entre casos).
- **FR-009**: La suite completa MUST poder ejecutarse con un único comando y reportar el resultado (verde/rojo) de forma clara.
- **FR-010**: La suite MUST generar un **reporte de cobertura** de líneas y alcanzar **≥ 80%** en las tres capas: **dominio** (casos de uso, enums), **datos** (modelos/`fromJson`, repositorio, data source, configuración) y **presentación** (ViewModels y estados).
- **FR-011**: La suite MUST incluir pruebas unitarias de la capa de **datos**: `fromJson` de los modelos (incluida la conversión de géneros y `backdrop_path`), el **repositorio** (mapeo de la respuesta a entidades, cálculo de "hay más páginas", y lanzar en error/vacío) y la construcción de URLs de imagen.
- **FR-012**: La suite MUST incluir pruebas unitarias de la capa de **dominio**: los casos de uso delegan correctamente en el repositorio, y la resolución de género por id (conocido y desconocido).

### Key Entities *(include if feature involves data)*

- **Datos simulados (fixtures)**: conjuntos de datos de prueba (listados de películas, detalle) que sustituyen la respuesta real del proveedor.
- **Doble de prueba del repositorio/casos de uso**: sustituto controlable que devuelve datos simulados o provoca errores a demanda.
- **Observador de estado**: mecanismo que registra la secuencia de estados emitidos por un ViewModel para su aserción.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de los ViewModels de presentación (catálogo, búsqueda, detalle) tiene al menos una prueba que verifica la transición carga → éxito y otra carga → error.
- **SC-002**: Los recorridos principales (catálogo, búsqueda, listado→detalle→volver, cargar más al hacer scroll) están cubiertos por al menos una prueba de integración cada uno.
- **SC-003**: La suite completa se ejecuta de forma reproducible sin acceso a la red y sin credenciales, y pasa al 100% en local.
- **SC-004**: Ninguna prueba depende de esperas arbitrarias de tiempo; las que involucran debounce controlan el reloj de forma explícita.
- **SC-005**: Una regresión introducida a propósito en la lógica de estado de un ViewModel hace fallar al menos una prueba (las pruebas detectan roturas reales).
- **SC-006**: La cobertura de líneas de las capas de **dominio**, **datos** y **presentación** es **≥ 80%**, medida con el reporte de cobertura de la suite (`flutter test --coverage`).
- **SC-007**: Las tres capas (dominio, datos, presentación) tienen pruebas unitarias propias; ninguna queda sin al menos una prueba de sus reglas clave.

## Assumptions

- **Restricciones de herramientas indicadas por el usuario** (se documentan aquí por ser decisiones dadas, aunque son de implementación):
  - Los dobles de prueba (mocks) del repositorio/providers se crean con **mockito**.
  - Las pruebas de integración usan el **driver de Flutter** (`integration_test`/`flutter_driver`).
  - Los tests de ViewModel siguen el patrón de escuchar el estado del provider con `container.listen(provider, (prev, next) {…}, fireImmediately: true)` para aseverar las transiciones, análogo al ejemplo `fetchCifsBco`.
- Se cubre únicamente el dominio **Películas** (alcance actual de la app); no se añaden pruebas de Series.
- La app expone su estado de presentación mediante un tipo de estado con variantes de carga/éxito/error, que es lo que las pruebas aseveran.
- La app ya cuenta con inyección de dependencias que permite sustituir el repositorio/casos de uso por un doble de prueba en el entorno de test.
- Decisión (ver Clarifications): se **migra totalmente a mockito** y se **retira mocktail**. Las pruebas **unitarias de ViewModels** se reescriben en mockito; los **widget tests actuales se eliminan** y sus flujos (catálogo, búsqueda, detalle, navegación) pasan a cubrirse con las **pruebas de integración** (driver de Flutter). La suite final = **unitarias (ViewModels) + integración (driver)**.
