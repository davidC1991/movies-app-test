# Contract: `MovieService` (retrofit) — endpoints TMDB

**File**: `lib/features/home/data/datasources/api/movie_service.dart`
**Base URL**: `https://api.themoviedb.org/3` · **Auth**: header `Authorization: Bearer <token>` (vía Dio)

```dart
@RestApi()
abstract class MovieService {
  factory MovieService(Dio dio, {String baseUrl}) = _MovieService;

  @GET('/movie/popular')
  Future<MovieResponseModel> getPopularMovies({@Query('page') int page = 1});

  @GET('/movie/top_rated')
  Future<MovieResponseModel> getTopRatedMovies({@Query('page') int page = 1});

  @GET('/movie/{id}')
  Future<MovieDetailModel> getMovieDetail(@Path('id') int id);

  @GET('/search/movie')
  Future<MovieResponseModel> searchMovies({
    @Query('query') required String query,
    @Query('page') int page = 1,
  });
}
```

## Endpoints (referencia TMDB)

| Método | Path | Query/Path | Devuelve |
|--------|------|------------|----------|
| GET | `/movie/popular` | `page` | `MovieResponseModel` |
| GET | `/movie/top_rated` | `page` | `MovieResponseModel` |
| GET | `/movie/{id}` | `id` (path) | `MovieDetailModel` |
| GET | `/search/movie` | `query`, `page` | `MovieResponseModel` |

## Notas
- `getMovieDetail` cambia su retorno de `MovieModel` → `MovieDetailModel` (respuesta con más campos).
- `language`/`region` se omiten (idioma por defecto del servicio, fuera de alcance).
- Imágenes: `https://image.tmdb.org/t/p/w342{poster_path}` (no es parte del servicio JSON).
