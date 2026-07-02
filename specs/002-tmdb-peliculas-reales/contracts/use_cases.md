# Contract: Repositorio, casos de uso y providers

## `MovieRepository` (domain) — `domain/repositories/movie_repository.dart`

```dart
abstract interface class MovieRepository {
  Future<PageResult<Movie>> getPopular({int page = 1});
  Future<PageResult<Movie>> getTopRated({int page = 1});
  Future<MovieDetail> getDetail(int id);
  Future<PageResult<Movie>> search(String query, {int page = 1});
}
```

- `PageResult<T>` (domain): `{ List<T> items, int page, bool hasMore }` — evita exponer el modelo de respuesta; lleva la info de paginación al ViewModel.
- Los métodos devuelven **entidades**; en error **lanzan** (el ViewModel usa try/catch).

## `MovieRepositoryRemote` (data) — comportamiento

| Operación | Respuesta del data source | Resultado |
|-----------|---------------------------|-----------|
| getPopular/getTopRated/search | `SuccessApiResponse(MovieResponseModel)` | `PageResult(items, page, hasMore = page < totalPages)` |
| " | `EmptyApiResponse` | `PageResult([], page, hasMore=false)` |
| " | `ErrorApiResponse` | **throw** |
| getDetail | `SuccessApiResponse(MovieDetailModel)` | `MovieDetail` |
| getDetail | `ErrorApiResponse` | **throw** |

## Casos de uso (domain) — `domain/usecases/`

```dart
class GetPopularMovies { Future<PageResult<Movie>> call({int page = 1}); }
class GetTopRatedMovies { Future<PageResult<Movie>> call({int page = 1}); }
class GetMovieDetail   { Future<MovieDetail> call(int id); }
class SearchMovies     { Future<PageResult<Movie>> call(String query, {int page = 1}); }
```
Cada uno inyecta `MovieRepository` y delega en el método homónimo.

## Data source — `MovieDataSource` (abstracto)

```dart
abstract interface class MovieDataSource {
  Future<ApiResponse<MovieResponseModel>> getPopular({int page = 1});
  Future<ApiResponse<MovieResponseModel>> getTopRated({int page = 1});
  Future<ApiResponse<MovieDetailModel>> getDetail(int id);
  Future<ApiResponse<MovieResponseModel>> search(String query, {int page = 1});
}
```
`MovieDataSourceRemote` (con `ApiResponseHandlerMixin`) inyecta `MovieService` y ejecuta `executeApiCall(service.<método>(...))`.

## Providers (presentation/DI) — `presentation/providers/home_providers.dart`

```dart
final movieServiceProvider = Provider<MovieService>((ref) => MovieService(ref.read(dioProvider)));
final movieDataSourceProvider = Provider<MovieDataSource>((ref) => MovieDataSourceRemote(ref.read(movieServiceProvider)));
final movieRepositoryProvider = Provider<MovieRepository>((ref) => MovieRepositoryRemote(ref.read(movieDataSourceProvider)));

final getPopularMoviesProvider = Provider((ref) => GetPopularMovies(ref.read(movieRepositoryProvider)));
final getTopRatedMoviesProvider = Provider((ref) => GetTopRatedMovies(ref.read(movieRepositoryProvider)));
final getMovieDetailProvider    = Provider((ref) => GetMovieDetail(ref.read(movieRepositoryProvider)));
final searchMoviesProvider      = Provider((ref) => SearchMovies(ref.read(movieRepositoryProvider)));
```

## `HomeViewModel` — `presentation/viewmodels/home_view_model.dart`

```dart
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, UIState<PagedMovies>>(HomeViewModel.new);

class HomeViewModel extends Notifier<UIState<PagedMovies>> {
  @override
  UIState<PagedMovies> build() { _load(); return const UILoading(); }

  Future<void> _load() async { /* page 1 → UISuccess(PagedMovies) | UIFail */ }
  Future<void> loadMore() async { /* page+1, anexa, isLoadingMore/loadMoreError */ }
  Future<void> retry() => _load();
}
```
Nota: el data source expone `movieDataSourceProvider` de nuevo (retorno del provider intermedio) para permitir overrides en tests.
