import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/movie_detail_model.dart';
import '../../models/movie_response_model.dart';

part 'movie_service.g.dart';

/// Cliente REST autogenerado (retrofit) para los endpoints de TMDB.
/// Recibe el `Dio` y el `baseUrl`; expone los paths y devuelve `Future`.
/// La implementacion (`_MovieService`) la genera `retrofit_generator`.
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
