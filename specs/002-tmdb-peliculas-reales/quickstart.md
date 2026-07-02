# Quickstart: Consumo real de películas (TMDB)

**Feature**: `002-tmdb-peliculas-reales` | **Date**: 2026-07-01

## 1. Pasos manuales (los haces tú)

1. Crea una cuenta en https://www.themoviedb.org y verifícala.
2. Ve a **Settings → API** y copia el **API Read Access Token** (v4, empieza por `eyJ...`).
3. En la raíz del proyecto crea el archivo **`.env`**:
   ```env
   TMDB_TOKEN=eyJhbGciOi... (tu Read Access Token)
   ```
   > No lo subas a git (ya estará en `.gitignore`). Hay una plantilla en `.env.example`.

## 2. Dependencias

```bash
flutter pub add flutter_dotenv cached_network_image
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

`pubspec.yaml` debe declarar el asset:
```yaml
flutter:
  assets:
    - .env
```

## 3. Ejecutar

```bash
flutter run
```
La app carga automáticamente el listado **Popular** de TMDB (pósters + título + rating) con scroll infinito.

## 4. Verificar

- **Éxito**: al abrir, se ven películas reales; al hacer scroll al final se cargan más (footer con spinner).
- **Vacío**: (raro en Popular) muestra estado vacío claro.
- **Error**: sin `.env`/token inválido o sin red → mensaje de error + botón **Reintentar**.
- **Pósters faltantes**: se muestra un placeholder, no se rompe el layout.

## 5. Reglas arquitectónicas (verificación)

```bash
# domain sin imports a data/presentation
grep -rn "features/home/data\|features/home/presentation" lib/features/home/domain && echo "VIOLACIÓN" || echo "OK"
# modelos confinados a data
grep -rn "MovieModel\|MovieDetailModel\|MovieResponseModel" lib/features/home/domain lib/features/home/presentation && echo "VIOLACIÓN" || echo "OK"
flutter analyze
```

## Notas
- Las operaciones **Top Rated, Detalle y Búsqueda** quedan disponibles como casos de uso (`GetTopRatedMovies`, `GetMovieDetail`, `SearchMovies`) para sus pantallas futuras; en esta feature no tienen UI.
- El `session_id` de TMDB **no** se usa (solo aplica a acciones de usuario).
