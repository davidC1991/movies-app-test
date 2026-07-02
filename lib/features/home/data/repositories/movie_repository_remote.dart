import '../../../../core/api/remote/api_response.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/page_result.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_data_source.dart';
import '../models/movie_response_model.dart';

/// Implementación del repositorio (data). Se le inyecta el `MovieDataSource`
/// abstracto. Usa los callbacks de `ApiResponse` para decidir qué entrega al
/// domain: success/empty → entidades; error → lanza.
class MovieRepositoryRemote implements MovieRepository {
  final MovieDataSource _dataSource;

  const MovieRepositoryRemote(this._dataSource);

  @override
  Future<PageResult<Movie>> getPopular({int page = 1}) =>
      _toPageResult(_dataSource.getPopular(page: page));

  @override
  Future<PageResult<Movie>> getTopRated({int page = 1}) =>
      _toPageResult(_dataSource.getTopRated(page: page));

  @override
  Future<PageResult<Movie>> search(String query, {int page = 1}) =>
      _toPageResult(_dataSource.search(query, page: page));

  @override
  Future<MovieDetail> getDetail(int id) async {
    final response = await _dataSource.getDetail(id);
    return response.when(
      // Un MovieDetailModel es-un MovieDetail (LSP): se devuelve directo.
      onSuccess: (success) => success.body,
      onEmpty: (_) => throw ErrorApiResponse(
        httpErrorMessage: 'Sin datos de la película',
        httpStatusCode: 404,
      ),
      onError: (error) => throw error,
    );
  }

  /// Convierte una respuesta de listado en `PageResult<Movie>`.
  Future<PageResult<Movie>> _toPageResult(
    Future<ApiResponse<MovieResponseModel>> future,
  ) async {
    final response = await future;
    return response.when(
      onSuccess: (success) => PageResult<Movie>(
        items: success.body.results,
        page: success.body.page,
        hasMore: success.body.page < success.body.totalPages,
      ),
      onEmpty: (_) => const PageResult<Movie>(items: [], page: 1, hasMore: false),
      onError: (error) => throw error,
    );
  }
}
