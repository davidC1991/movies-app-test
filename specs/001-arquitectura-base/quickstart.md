# Quickstart: Arquitectura Base (Clean Architecture Scaffold)

**Feature**: `001-arquitectura-base` | **Date**: 2026-07-01

Guía para levantar y verificar la base arquitectónica una vez implementada.

## Prerrequisitos

- Flutter 3.38.6 / Dart 3.10.7 (o superior ≥ 3.35.7)
- Emulador/dispositivo iOS o Android

## 1. Añadir dependencias

```bash
flutter pub add flutter_riverpod freezed_annotation fluro
flutter pub add --dev build_runner freezed mocktail
```

## 2. Generar código de Freezed

```bash
dart run build_runner build --delete-conflicting-outputs
```

Genera `*.freezed.dart` para `Movie`, `MovieModel`, `Result<T>`, `UIState<T>` y `Failure`.

## 3. Ejecutar la app

```bash
flutter run
```

Se navega a `HomeScreen` a través del `FluroRouter`.

## 4. Verificar el flujo end-to-end

1. En la pantalla `home`, pulsar el **botón de verificación**.
2. Observar el estado **loading** (indicador) mientras el mock resuelve el `Future`.
3. Al resolver, ver la lista de películas placeholder (estado **success**).
4. (Opcional) Activar el flag de fallo del mock y confirmar que se muestra el estado **fail**.

**Criterio de éxito (SC-001)**: el valor mostrado proviene del data source mockeado tras atravesar data → domain → presentation.

## 5. Ejecutar pruebas

```bash
flutter test
```

Debe pasar:
- `get_movies_test.dart` — caso de uso con repositorio mockeado (success/empty/fail).
- `movie_repository_impl_test.dart` — mapeo model→entidad y variantes de `Result`.

## 6. Verificar reglas arquitectónicas

```bash
# La capa domain no debe importar data ni presentation (SC-003)
grep -rn "features/home/data\|features/home/presentation" lib/features/home/domain && echo "VIOLACIÓN" || echo "OK: domain aislado"

# MovieModel confinado a data (SC-004a)
grep -rn "MovieModel" lib/features/home/domain lib/features/home/presentation && echo "VIOLACIÓN" || echo "OK: modelo confinado"

# Análisis estático sin errores (SC-006)
flutter analyze
```

## Añadir una nueva feature (replicar el patrón)

1. `lib/features/<nombre>/` con subcarpetas `data/{datasources,models,repositories}`, `domain/{entities,repositories,usecases}`, `presentation/{navigation,providers,viewmodels,ui/widgets}`.
2. Reutilizar `Result<T>`, `UIState<T>` y `Failure` de `core/` (lógica Dart pura).
3. Definir las rutas hijas del feature en `presentation/navigation/` y registrarlas en el router global `lib/navigation/app_router.dart`.
