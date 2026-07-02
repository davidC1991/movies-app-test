# Feature Specification: Catálogo, búsqueda y detalle de películas

**Feature Branch**: `003-catalogo-detalle-busqueda`
**Created**: 2026-07-01
**Status**: Draft
**Input**: User description: "Definir las pantallas que requiere la app: películas categorizadas por Popular y Top Rated (pantalla principal); al pulsar una, va a Detalle; arriba en el home una barra buscadora que filtra las películas y actualiza la pantalla, con debounce para esperar a que el usuario termine de escribir antes de hacer el request; al volver, limpia y muestra la vista por defecto. La UI debe reutilizar componentes comunes entre pantallas (sistema de diseño reutilizable)."

## Clarifications

### Session 2026-07-01

- Q: ¿Cuánto debe esperar el debounce de búsqueda tras la última pulsación? → A: 400 ms (equilibrio estándar; coincide con el design system)
- Q: ¿Qué longitud mínima de texto dispara la búsqueda? → A: Cualquier texto no vacío (≥1 carácter); en blanco o solo espacios se trata como "sin búsqueda"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Explorar el catálogo por categorías (Priority: P1)

Como usuario, al abrir la app quiero ver películas organizadas en categorías reconocibles —**Populares** y **Mejor valoradas**— para descubrir contenido de un vistazo, con su póster y calificación, y poder desplazarme para ver más.

**Why this priority**: Es la pantalla de entrada y el corazón de la app. Sin ella no hay producto: entrega valor por sí sola (descubrir películas) aunque no existieran búsqueda ni detalle.

**Independent Test**: Se puede probar abriendo la app sin escribir nada ni navegar a otra pantalla: deben aparecer las dos categorías con sus películas (póster + calificación) y permitir avanzar por el listado.

**Acceptance Scenarios**:

1. **Given** el usuario abre la app con conexión, **When** carga la pantalla principal, **Then** ve las categorías "Populares" y "Mejor valoradas" con películas mostrando póster y calificación.
2. **Given** el catálogo está cargado, **When** el usuario se desplaza hasta el final de una categoría, **Then** se cargan más resultados automáticamente sin recargar toda la pantalla.
3. **Given** la carga inicial está en curso, **When** aún no llegan los datos, **Then** se muestra un estado de carga (esqueleto/indicador) en lugar de una pantalla vacía.

---

### User Story 2 - Buscar películas por nombre (Priority: P2)

Como usuario, quiero una barra de búsqueda en la parte superior de la pantalla principal para escribir el nombre de una película y ver los resultados filtrados, sin que la app dispare una petición por cada tecla, y poder volver al estado inicial fácilmente.

**Why this priority**: Aumenta mucho la utilidad tras tener el catálogo, pero la app ya es viable sin ella. Depende de que exista la pantalla principal (P1).

**Independent Test**: Se puede probar escribiendo un término en la barra y comprobando que la pantalla muestra resultados coincidentes; y que al limpiar/volver se restaura el catálogo por categorías.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal, **When** escribe un término y hace una pausa al terminar de teclear, **Then** la pantalla se actualiza con las películas que coinciden con el nombre.
2. **Given** el usuario está escribiendo, **When** teclea varios caracteres seguidos sin pausa, **Then** la app espera a que termine (debounce) antes de realizar la búsqueda, evitando peticiones por cada pulsación.
3. **Given** hay una búsqueda activa con resultados, **When** el usuario borra el texto o pulsa volver/limpiar, **Then** la vista se restablece al catálogo por categorías por defecto.
4. **Given** el usuario busca un término sin coincidencias, **When** la búsqueda finaliza, **Then** se muestra un estado vacío claro ("sin resultados") en lugar de una lista en blanco.

---

### User Story 3 - Ver el detalle de una película (Priority: P3)

Como usuario, al pulsar una película quiero abrir una pantalla de detalle con su información ampliada —imagen, título, calificación, géneros y sinopsis— para decidir si me interesa.

**Why this priority**: Completa el recorrido de descubrimiento, pero el catálogo y la búsqueda ya aportan valor sin él. Depende de poder seleccionar una película (P1/P2).

**Independent Test**: Se puede probar pulsando cualquier película del catálogo o de los resultados de búsqueda y verificando que se abre una pantalla con su información ampliada, y que se puede volver a la lista anterior.

**Acceptance Scenarios**:

1. **Given** el usuario ve una película en el catálogo o en resultados de búsqueda, **When** la pulsa, **Then** navega a una pantalla de detalle con imagen, título, calificación, géneros y sinopsis.
2. **Given** el usuario está en el detalle, **When** pulsa volver, **Then** regresa a la lista anterior conservando su posición/estado.
3. **Given** el detalle está cargando o falla, **When** no hay datos disponibles, **Then** se muestra un estado de carga o de error con opción de reintentar.

---

### Edge Cases

- **Sin conexión / error de red**: cualquier pantalla (catálogo, búsqueda, detalle) muestra un estado de error legible con opción de reintentar, no una pantalla en blanco ni un fallo silencioso.
- **Búsqueda con texto en blanco o solo espacios**: se trata como "sin búsqueda" y se mantiene/restaura el catálogo por defecto.
- **Categoría o página sin más resultados**: al llegar al final no se intenta cargar indefinidamente ni se muestra un error.
- **Película sin imagen, sin calificación o sin sinopsis**: se muestra un marcador de posición o se omite el dato con elegancia, sin romper el diseño.
- **Búsqueda rápida encadenada**: si el usuario cambia el término antes de que responda la búsqueda anterior, prevalece el resultado del último término escrito.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La pantalla principal MUST mostrar películas agrupadas al menos en las categorías "Populares" y "Mejor valoradas".
- **FR-002**: Cada película listada MUST mostrar, como mínimo, su imagen (póster) y su calificación.
- **FR-003**: El sistema MUST permitir avanzar dentro de cada categoría cargando más resultados de forma incremental al desplazarse (scroll), sin recargar toda la pantalla.
- **FR-004**: La pantalla principal MUST incluir, en su parte superior, una barra de búsqueda por nombre de película.
- **FR-005**: La búsqueda MUST aplicar una espera (debounce) de **400 ms** tras la última pulsación antes de ejecutar la petición, evitando una petición por cada carácter.
- **FR-006**: Al ejecutar una búsqueda, el sistema MUST actualizar la pantalla mostrando únicamente las películas que coinciden con el término. La búsqueda se dispara con cualquier texto no vacío (≥1 carácter); un texto en blanco o compuesto solo por espacios se trata como "sin búsqueda".
- **FR-007**: Al limpiar el texto de búsqueda o al volver, el sistema MUST restaurar la vista por defecto (catálogo por categorías).
- **FR-008**: El sistema MUST permitir seleccionar una película desde el catálogo o desde los resultados de búsqueda para abrir su detalle.
- **FR-009**: La pantalla de detalle MUST mostrar información ampliada de la película: imagen, título, calificación, géneros y sinopsis.
- **FR-010**: Toda pantalla MUST comunicar de forma explícita sus estados de carga, vacío y error, ofreciendo reintentar cuando aplique.
- **FR-011**: La interfaz MUST construirse a partir de un conjunto de componentes visuales reutilizables y consistentes, compartidos entre las pantallas, de modo que los elementos comunes (tarjetas de película, encabezados de sección, barra de búsqueda, estados) se reutilicen en lugar de duplicarse.
- **FR-012**: La app MUST aplicar una identidad visual consistente (tema único) en todas las pantallas.

### Key Entities *(include if feature involves data)*

- **Película (resumen)**: representación breve para listados y resultados de búsqueda; atributos clave: identificador, título, imagen (póster), calificación.
- **Detalle de película**: representación ampliada; atributos clave: título, imagen, calificación, géneros, sinopsis y metadatos (p. ej. año/duración cuando estén disponibles).
- **Categoría**: agrupación de películas para el catálogo (p. ej. "Populares", "Mejor valoradas").
- **Consulta de búsqueda**: término introducido por el usuario que filtra el catálogo por nombre.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Desde que se abre la app, el usuario ve contenido del catálogo (al menos una categoría con películas) en menos de 3 segundos con una conexión normal.
- **SC-002**: Al escribir un término y detenerse, el usuario ve resultados de búsqueda en menos de 2 segundos sin haber provocado una petición por cada carácter tecleado.
- **SC-003**: El usuario puede pasar del catálogo al detalle de una película y volver en 2 toques o menos.
- **SC-004**: El 100% de las pantallas comunican de forma visible sus estados de carga, vacío y error (ninguna pantalla queda en blanco ante fallo o ausencia de datos).
- **SC-005**: Los componentes visuales comunes (tarjeta de película, barra de búsqueda, encabezado de sección, estados de carga/vacío/error) se reutilizan en las distintas pantallas sin duplicación de su definición.
- **SC-006**: La identidad visual (colores, tipografía, espaciados) es consistente entre catálogo, búsqueda y detalle.

## Assumptions

- El alcance es **solo películas**; las series quedan fuera de esta feature (el requisito original es "Películas y/o Series", cubierto con películas).
- Los datos provienen del proveedor de catálogo ya integrado en la app (feature 002), incluyendo listados de Populares, Mejor valoradas, búsqueda por nombre y detalle por identificador.
- La app se orienta a un único tema visual (modo oscuro de estética tipo streaming) como decisión de producto; no se contempla conmutar tema claro/oscuro en esta feature.
- La conectividad es intermitente pero mayoritariamente disponible; se prioriza degradar con estados claros ante fallos.
- La reutilización de UI se materializa mediante un sistema de diseño compartido a nivel de la app (componentes organizados por niveles: elementos base, combinaciones y bloques de pantalla).
