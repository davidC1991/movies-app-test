# Convenciones de estructura por feature

Cada feature vive en `lib/features/<feature>/` y sigue **Clean Architecture** con tres
capas. La regla de dependencia apunta hacia adentro: `presentation → domain ← data`.
La capa `domain` **no importa** nada de `data` ni de `presentation`.

```text
lib/features/<feature>/
├── data/
│   ├── datasources/     # Fuentes de datos (mock, API, caché). Devuelven modelos.
│   ├── models/          # Modelos de datos (Freezed) + toEntity(). Confinados a data.
│   └── repositories/    # Implementación de los contratos; mapea model→entidad; envuelve en Result.
├── domain/
│   ├── entities/        # Entidades de dominio (Freezed). Puras, sin conocer data/presentation.
│   ├── repositories/    # Contratos abstractos (interfaces). Devuelven Result<T>.
│   └── usecases/        # Casos de uso: única puerta de entrada para la presentación.
└── presentation/
    ├── navigation/      # Rutas hijas del feature; se exponen al router global (lib/navigation).
    ├── providers/       # DI manual con Riverpod: dataSource → repositorio → caso de uso.
    ├── viewmodels/      # ViewModels (Notifier) que invocan el caso de uso y exponen UIState<T>.
    └── ui/
        ├── <screen>.dart  # Pantallas.
        └── widgets/       # Widgets reutilizables del feature.
```

## Tipos compartidos (`lib/core/`)

Lógica **Dart pura** (sin dependencias de Flutter), reutilizable por todas las features:

- `core/result/result.dart` — `Result<T>`: `empty` / `success` / `fail`. Lo produce el repositorio.
- `core/state/ui_state.dart` — `UIState<T>`: `loading` / `success` / `fail`. Estado de los ViewModels.
- `core/error/failure.dart` — `Failure`: fallos de dominio.

## Routing global (`lib/navigation/`)

`app_router.dart` construye el `FluroRouter` principal y agrega las rutas que cada
feature expone desde su `presentation/navigation/`. Va fuera de `core` porque depende de Flutter.

## Reglas verificables

- `domain/` no importa `data/` ni `presentation/`.
- Los modelos (`*Model`) no se importan fuera de `data/`.
- La presentación resuelve dependencias vía providers de Riverpod (sin instanciación manual).

## Cómo añadir una nueva feature

1. Crear `lib/features/<nombre>/` replicando el árbol de arriba.
2. Reutilizar `Result<T>`, `UIState<T>` y `Failure` de `core/`.
3. Definir rutas en `presentation/navigation/` y registrarlas en `lib/navigation/app_router.dart`.
