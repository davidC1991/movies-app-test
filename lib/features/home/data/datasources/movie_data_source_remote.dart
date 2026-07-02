import '../../../../core/api/remote/api_response.dart';
import '../../../../core/api/remote/api_response_handler_mixin.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_response_model.dart';
import 'api/movie_service.dart';
import 'movie_data_source.dart';

/// Implementación remota del data source. Inyecta el `MovieService` (retrofit)
/// y envuelve cada llamada con `ApiResponseHandlerMixin` → `ApiResponse<T>`.
class MovieDataSourceRemote with ApiResponseHandlerMixin implements MovieDataSource {
  final MovieService _service;

  MovieDataSourceRemote(this._service);

  @override
  Future<ApiResponse<MovieResponseModel>> getPopular({int page = 1}) {
    return executeApiCall(_service.getPopularMovies(page: page));
  }

  @override
  Future<ApiResponse<MovieResponseModel>> getTopRated({int page = 1}) {
    return executeApiCall(_service.getTopRatedMovies(page: page));
  }

  @override
  Future<ApiResponse<MovieDetailModel>> getDetail(int id) {
    return executeApiCall(_service.getMovieDetail(id));
  }

  @override
  Future<ApiResponse<MovieResponseModel>> search(String query, {int page = 1}) {
    return executeApiCall(_service.searchMovies(query: query, page: page));
  }
}
