import '../../../../core/api/remote/api_response.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_response_model.dart';

/// Contrato del data source (capa data). Devuelve la respuesta cruda de la API
/// envuelta en `ApiResponse<Model>`.
abstract interface class MovieDataSource {
  Future<ApiResponse<MovieResponseModel>> getPopular({int page = 1});

  Future<ApiResponse<MovieResponseModel>> getTopRated({int page = 1});

  Future<ApiResponse<MovieDetailModel>> getDetail(int id);

  Future<ApiResponse<MovieResponseModel>> search(String query, {int page = 1});
}
