<!-- SPECKIT START -->
Active feature: `002-tmdb-peliculas-reales` (consumo real de TMDB).
For technologies, project structure, and commands, read the current plan:
`specs/002-tmdb-peliculas-reales/plan.md` (and `research.md`, `data-model.md`,
`contracts/`, `quickstart.md`). Base architecture: `specs/001-arquitectura-base/`.

Feature 002: auth con Read Access Token estático (Bearer) leído de `.env`
(flutter_dotenv); NO session_id. 4 casos de uso (GetPopularMovies, GetTopRatedMovies,
GetMovieDetail, SearchMovies); UI solo del listado Popular con scroll infinito
(PagedMovies dentro de UIState) + póster (cached_network_image w342) + rating.
El repositorio devuelve PageResult<Movie>/MovieDetail; el data source usa retrofit
MovieService real + ApiResponse.

Stack: Flutter 3.38.6 / Dart 3.10.7 · flutter_riverpod (manual DI, no codegen) ·
freezed + build_runner · fluro (routing) · flutter_test + mocktail.
Architecture: feature-first Clean Architecture (data/domain/presentation) + `core/`.
MVVM in presentation (Notifier ViewModels → `UIState<T>`). Repository returns
`Result<T>` (empty/success/fail) and is the only place `MovieModel → Movie` mapping
happens. domain must not import data/presentation; `MovieModel` stays in data.
<!-- SPECKIT END -->
